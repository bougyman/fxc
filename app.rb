require "innate"
require_relative "lib/fxc"
require_relative 'node/proxy'

require FXC::ROOT/"model/init"
require FXC::ROOT/"lib/rack/middleware"

Innate::Response.options.headers['Content-Type'] = 'freeswitch/xml'

Innate.middleware! do |mw|
  mw.use FXC::Rack::Middleware
  mw.use Rack::CommonLogger
  mw.innate
end

if $0 == __FILE__
  Innate.start :root => FXC::ROOT.to_s, :file => __FILE__
end
