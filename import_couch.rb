require 'makura'
require 'pp'
require 'nokogiri'

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
    pp xml
    throw :ignore
    # TODO
  end

  def loopback(xml, doc)
    throw :ignore
  end

  def _settings(xml, doc)
    doc[:settings] = settings = {}
    xml.xpath('settings/param').each do |param|
      settings[param[:name]] = param[:value]
    end
  end
end

Makura::Model.server = 'http://jimmy:5984'
Makura::Model.database = "fxc_spec_#{Time.now.to_i}"
DB = Makura::Model.database

modules_xml = File.expand_path('~/conf/autoload_configs/modules.conf.xml')
Nokogiri::XML(File.read(modules_xml)).xpath('/configuration/modules/load[@module]').each do |tag|
  mod = tag['module'].sub(/^mod_/, '')
  mod_xml = File.join(File.dirname(modules_xml), "#{mod}.conf.xml")
  begin
    xml = Nokogiri::XML(File.read(mod_xml)).xpath('/configuration')
  rescue Errno::ENOENT
    $stderr.puts "No config file found for #{mod_xml}"
    next
  end

  doc = {
    name: "#{mod}.conf",
    database: nil,
    '_id' => "#{mod}.conf",
  }

  catch :ignore do
    Convert.send(mod, xml, doc)
    DB.save(doc)

    pp DB[doc['_id']]
  end

end
