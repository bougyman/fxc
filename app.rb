require "innate"
require_relative "lib/fxc"
Dir.glob(Fxc::PATH + "/node/*.rb").each { |node|
  p node
  require node
}
require Fxc::PATH + "lib/rack/middleware"
Innate.middleware! do |mw|
  mw.use Fxc::Rack::Middleware
  mw.innate
end

if $0 == __FILE__
  Innate.start :root => Fxc::PATH, :file => __FILE__
end