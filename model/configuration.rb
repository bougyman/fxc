module FXC
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
