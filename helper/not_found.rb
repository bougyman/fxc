module Innate
  module Helper
    module NotFound
      def not_found
        respond FXC::Proxy.render_view(:not_found), 200, 'Content-Type' => 'freeswitch/xml'
      end
    end
  end
end
