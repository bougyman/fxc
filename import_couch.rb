require 'makura'
require 'tsort'
require 'pp'
require 'nokogiri'

class Hash
  include TSort
  alias tsort_each_node each_key
  def tsort_each_child(node, &block)
    fetch(node).each(&block)
  end
end

module Convert
  module_function

  def xml_curl(xml, doc)
    doc[:bindings] = bindings = {}

    xml.xpath('bindings/binding').each do |binding|
      bindings[binding[:name]] = params = {}

      binding.xpath('param').each do |param|
        if param[:name] == 'gateway-url'
          params[:config] = {
            'gateway-url' => param[:value],
            'bindings' => param[:bindings],
          }
        else
          params[param[:name]] = param[:value]
        end
      end
    end
  end

  def console(xml, doc)
    doc[:mappings] = mappings = {}
    xml.xpath('mappings/map').each do |map|
      mappings[map[:name]] = map[:value]
    end

    _settings(xml, doc)
  end

  def logfile(xml, doc)
    doc[:profiles] = profiles = {}
    xml.xpath('profiles/profile').each do |profile|
      profiles[profile[:name]] = ph = {}
      _settings(profile, ph)
      ph[:mappings] = pm = {}
      profile.xpath('mappings/map').each do |map|
        pm[map[:name]] = map[:value].scan(/[^\s,]+/)
      end
    end

    _settings(xml, doc)
  end

  def enum(xml, doc)
    _settings(xml, doc)
    doc[:routes] = routes = []
    xml.xpath('routes/route').each do |route|
      routes << route.attributes
    end
  end

  def xml_cdr(xml, doc)
    doc[:description] = 'XML CDR cURL Logger'
    _settings(xml, doc)
  end

  def cdr_csv(xml, doc)
    doc[:description] = 'CDR CSV Format'
    _settings(xml, doc)
    doc[:templates] = templates = {}
    xml.xpath('templates/template').each do |template|
      templates[template[:name]] = template.inner_text
    end
  end

  def event_socket(xml, doc)
    doc[:description] = 'Socket Client'
    _settings(xml, doc)
  end

  def sofia(xml, doc)
    doc[:global_settings] = global_settings = {}
    xml.xpath('global_settings/param').each do |param|
      global_settings[param[:name]] = param[:value]
    end

    doc[:profiles] = profiles = {}
    xml.xpath('profiles/profile').each do |profile|
      profiles[profile[:name]] = ph = {}
      _settings(profile, ph)

      ph[:aliases] = profile.xpath('aliases').map{|a| a[:name] }
      ph[:domains] = domains = {}
      profile.xpath('domains/domain').each do |domain|
        domains[domain[:name]] = {
          alias: domain[:alias] == 'true',
          parse: domain[:parse] == 'true',
        }
      end

      ph[:gateways] = gateways = {}

      xml.xpath('gateways/gateway').each do |gateway|
        gateways[gateway[:name]] = gh = {}
        gateway.xpath('param').each do |param|
          gh[param[:name]] = param[:value]
        end
      end
    end
  end

  def conference(xml, doc)
    doc[:advertise] = advertise = {}
    xml.xpath('advertise/room').each do |room|
      advertise[room[:name]] = room[:status]
    end

    doc['caller-controls'] = caller_controls = {}
    xml.xpath('caller-controls/group').each do |group|
      caller_controls[group[:name]] = gh = {}
      group.xpath('control').each do |control|
        gh[control[:action]] = control[:digits]
      end
    end

    doc['profiles'] = profiles = {}
    xml.xpath('profiles/profile').each do |profile|
      profiles[profile[:name]] = ph = {}
      profile.xpath('param').each do |param|
        ph[param[:name]] = param[:value]
      end
    end
  end

  def fifo(xml, doc)
    _settings(xml, doc)

    doc['fifos'] = fifos = {}
    xml.xpath('fifos/fifo').each do |fifo|
      fifos[fifo[:name]] = fh = {}
      fifo.attributes.each do |key, attribute|
        fh[key] = attribute.value unless key == "name"
      end

      fh[:members] = members = {}
      fifo.xpath('member').each do |member|
        members[member.text] = mh = {}
        member.attributes.each do |key, attribute|
          mh[key] = attribute.value
        end
      end
    end
  end

  def db(xml, doc)
    _settings(xml, doc)
  end

  def hash(xml, doc)
    doc[:remotes] = remotes = {}
    xml.xpath('remotes/remote').each do |remote|
      remotes[remote[:name]] = rh = {}
      remote.attributes.each do |key, attribute|
        rh[key] = attribute.value unless key == 'name'
      end
    end
  end

  def local_stream(xml, doc)
    doc[:directories] = directories = {}
    xml.xpath('directory').each do |directory|
      directories[directory[:name]] = dh = {}
      dh[:path] = directory[:path]
      directory.xpath('param').each do |param|
        dh[param[:name]] = param[:value]
      end
    end
  end

  def spandsp(xml, doc)
    doc[:descriptors] = descriptors = {}
    xml.xpath('descriptors/descriptor').each do |descriptor|
      descriptors[descriptor[:name]] = dh = {}
      descriptor.xpath('tone').each do |tone|
        dh[tone[:name]] = ta = []
        tone.xpath('element').each do |element|
          ta << tah = {}
          element.attributes.each do |key, attribute|
            tah[key] = attribute.value.to_i
          end
        end
      end
    end
  end

  def voicemail(xml, doc)
    _settings(xml, doc)

    doc[:profiles] = profiles = {}
    xml.xpath('profiles/profile').each do |profile|
      profiles[profile[:name]] = ph = {}

      profile.xpath('param').each do |param|
        ph[param[:name]] = param[:value]
      end

      ph[:email] = email = {}
      profile.xpath('email/param').each do |param|
        email[param[:name]] = param[:value]
      end
    end
  end

  def _settings(xml, doc)
    doc[:settings] = settings = {}
    xml.xpath('settings/param').each do |param|
      settings[param[:name]] = param[:value]
    end
  end

  def _parse(filename, parent = nil, deps = {}, xmls = {})
    deps[filename] ||= []

    node = Nokogiri::XML(File.read(filename))
    xmls[filename] = node
    node.xpath('//X-PRE-PROCESS[@cmd="include"]').each do |inc|
      glob = File.expand_path(inc[:data], File.dirname(filename))

      Dir.glob(glob){|path|
        deps[path] ||= []
        deps[filename] << path
        deps.tsort # check for cyclic dependencies.

        child = _parse(path, node, deps, xmls)
        inc.parent.add_child(child)
      }
    end

    if parent
      node.xpath('/include')
    else
      node.xpath('/configuration')
    end
  end
end

Makura::Model.server = 'http://jimmy:5984'
Makura::Model.database = "fxc_spec"
Makura::Model.database.destroy!
Makura::Model.database.create
DB = Makura::Model.database

modules_xml = File.expand_path('~/conf/autoload_configs/modules.conf.xml')
Nokogiri::XML(File.read(modules_xml)).xpath('/configuration/modules/load[@module]').each do |tag|
  mod = tag['module'].sub(/^mod_/, '')
  mod_xml = File.join(File.dirname(modules_xml), "#{mod}.conf.xml")
  begin
    xml = Convert._parse(mod_xml)
  rescue Errno::ENOENT
    warn "No config file found for #{mod_xml}"
    next
  end

  doc = {
    name: "#{mod}.conf",
    database: nil,
    '_id' => "#{mod}.conf",
  }

  catch :ignore do
    puts "Attempt conversion of #{mod}"
    if Convert.respond_to?(mod)
      Convert.send(mod, xml, doc)
      DB.save(doc)

      # pp DB[doc['_id']]
    else
      raise "No converter for #{mod}"
    end
  end
end
