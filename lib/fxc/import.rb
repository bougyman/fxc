require 'tsort'
require 'pp'
require 'nokogiri'
require 'makura'

class Hash
  include TSort
  alias tsort_each_node each_key
  def tsort_each_child(node, &block)
    fetch(node).each(&block)
  end
end

module FXC
  module ConverterHelper
    module_function
    def parse(filename, parent = nil, deps = {}, xmls = {})
      deps[filename] ||= []

      node = Nokogiri::XML(File.read(filename))
      xmls[filename] = node
      node.xpath('//X-PRE-PROCESS[@cmd="include"]').each do |inc|
        glob = File.expand_path(inc[:data], File.dirname(filename))

        Dir.glob(glob){|path|
          deps[path] ||= []
          deps[filename] << path
          deps.tsort # check for cyclic dependencies.

          parse(path, node, deps, xmls).children.each do |child|
            inc.parent.add_child(child)
          end
        }
      end

      if parent
        node.xpath('/include')
      else
        conf = node.xpath('/configuration')
        conf.empty? ? node : conf
      end
    end

    # Find the FreeSWITCH install path if running FSR on a local box with FreeSWITCH installed.
    # This will enable sqlite db access
    def find_freeswitch_install
      fs_install_paths = [
        ENV["HOME"], ENV["HOME"] + "/freeswitch",
        "/usr/local/freeswitch", "/opt/freeswitch", "/usr/freeswitch",
        "/home/freeswitch/freeswitch", '/home/freeswitch'
      ]
      fs_install_paths.unshift(ENV['FREESWITCH_PATH']) if ENV['FREESWITCH_PATH']
      good_path = fs_install_paths.find do |fs_path|
        warn("#{fs_path} is not a directory!") unless File.directory?(fs_path)
        warn("#{fs_path} is not readable by this user!") unless File.readable?(fs_path)
        fs_path.to_s if Dir["#{fs_path}/{conf,db}/"].size == 2
      end

      unless good_path
        warn("No FreeSWITCH install found, database and configuration functionality disabled")
        warn "You can specify the path to FreeSWITCH with the FREESWITCH_PATH env variable"
        exit 1
      end

      good_path
    end
  end

  class Converter
    def initialize(root = ConverterHelper.find_freeswitch_install, options = {})
      @root = File.expand_path(root)
      @opts = {
        couch_server: 'http://jimmy:5984',
        couch_db: 'fxc_spec',
        couch_preserve_db: false,
        couch_no_create: false,
        server: %x{hostname}.strip,
      }.merge(options)
    end

    def convert(tree)
      case tree
      when :configuration
        convert_configuration
      when :directory
         convert_directory 
      when :dialplan
        convert_dialplan
      end
    end

    def couchdb
      return @couchdb if @couchdb
      Makura::Model.server = @opts[:couch_server]
      Makura::Model.database = @opts[:couch_db]
      Makura::Model.database.destroy! unless @opts[:couch_preserve_db]
      Makura::Model.database.create unless @opts[:couch_no_create]
      @couchdb = Makura::Model.database
    end

    def convert_configuration

      require_relative 'import/configuration'

      read_configuration do |mod, xml|
        doc = {
          name: "#{mod}.conf",
          database: nil,
          '_id' => "#{@opts[:server]}_#{mod}.conf",
        }

        catch :ignore do
          puts "Attempt conversion of #{mod}"
          if Configuration.respond_to?(mod)
            Configuration.send(mod, xml, doc)
            rec = couchdb.save(doc)
            p rec

            # pp DB[doc['_id']]
          else
            raise "No converter for #{mod}"
          end
        end
      end
    end

    def read_configuration
      Nokogiri::XML(File.read(modules_xml)).xpath('/configuration/modules/load[@module]').each do |tag|
        mod = tag['module'].sub(/^mod_/, '')
        mod_xml = File.join(File.dirname(modules_xml), "#{mod}.conf.xml")
        begin
          xml = ConverterHelper.parse(mod_xml)
        rescue Errno::ENOENT
          warn "No config file found for #{mod_xml}"
          next
        end

        yield mod, xml
      end
    end

    def modules_xml
      File.join(@root, '/conf/autoload_configs/modules.conf.xml')
    end


    def convert_dialplan
      require_relative 'import/dialplan'
      read_dialplan do |xml|
        xml.xpath('context').each do |context|
          # do stuff with that
          FXC::Converter::Dialplan.parse_context(context, @opts[:server])
        end
      end
    end

    def read_dialplan(&block)
      Dir.glob(@root + '/conf/dialplan/*.xml').each do |context_xml|
        # read each file and parse it into its full xml (include x-pre-process)
        yield ConverterHelper.parse(context_xml)
      end
    end

    def convert_directory
      require_relative 'import/directory'
      read_directory do |xml|
        xml.xpath('include/domain').each do |domain|
          # do stuff with that
          doc = {server: @opts[:server]}
          FXC::Converter::Directory.parse_domain(domain, doc, couchdb)
          rec = couchdb.save(doc)
          p rec
        end
      end
    end

    def read_directory(&block)
      Dir.glob(@root + '/conf/directory/*.xml').each do |directory_xml|
        # read each file and parse it into its full xml (include x-pre-process)
        yield ConverterHelper.parse(directory_xml)
      end
    end
  end
end


if __FILE__ == $0
  converter = FXC::Converter.new
  #converter.convert(:configuration)
  converter.convert(:directory)
  #converter.convert(:dialplan)
end
