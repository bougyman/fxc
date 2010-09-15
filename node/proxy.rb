module FXC
  class Proxy
    Innate.node "/", self
    provide :html, engine: :None
    helper :not_found

    def index
      "Welcome to FXC!"
    end

    def configuration(name, hostname)
      response['Content-Type'] = 'freeswitch/xml'

      Configuration.render(name, hostname).to_s + "\n"

    rescue Makura::Error => ex
      Innate::Log.error(ex)
      not_found
    end
  end

end

require_relative 'directory'
require_relative 'dialplan'
