require 'makura'

Makura::Model.server = 'http://jimmy:5984'
Makura::Model.database = 'fxc'

root = File.expand_path("../couch/configuration", __FILE__)
glob = File.join(root, "**/*.js")

begin
  layout = Makura::Model.database["_design/configuration"] || {}
rescue Makura::Error::ResourceNotFound
  layout = {}
end

layout['language'] ||= 'javascript'
layout['_id'] ||= "_design/configuration"

Dir.glob(glob) do |file|
  keys = File.dirname(file).sub(root, '').scan(/[^\/]+/)
  doc = File.read(file)
  last = nil
  keys.inject(layout){|k,v| last = k[v] ||= {} }
  last[File.basename(file, '.js')] = doc
end

Makura::Model.database.save(layout)
