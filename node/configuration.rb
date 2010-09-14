require 'innate'
require 'makura'
Makura::Model.database = 'fxc'

module Fxc
  class Proxy
    Innate.node "/", self
    provide :html, engine: :None

    def index
      "Welcome to Fxc!"
    end

    def configuration(name, hostname)
      response['Content-Type'] = 'freeswitch/xml'

      Configuration.render(name, hostname).to_s + "\n"

    rescue Makura::Error => ex
      Innate::Log.error(ex)
      <<-XML
<document type="freeswitch/xml">
  <section name="result">
    <result status="not found" />
  </section>
</document>
      XML
    end
  end

  class Configuration
    include Makura::Model

    property :name
    property :server

    def self.render(name, hostname, opts = {})
      if name == "sofia.conf"
        Configuration.render_sofia(hostname)
      else
        Configuration.render_common(name, hostname)
      end
    end

    def self.render_common(name, hostname, opts = {})
      keys = [[name, hostname], [name, nil]]
      opts.merge!(:payload => {'keys' => keys}, 'Content-Type' => 'application/json', :limit => 1)
      database.post("_design/configuration/_list/#{name}/conf", opts)
    end

    def self.render_sofia(hostname, opts = {})
      database.get("_design/configuration/_list/sofia/sofia_profiles",
                   startkey: [hostname, 0],
                   endkey:   [hostname, 1])
    end
  end
end
