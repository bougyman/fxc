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

  doc.sub!(/function\(head, req\)\{/, <<-JS)
function(head, req){
  var each = function(obj, callback){
    var result = <></>;
    var tmp;

    for(key in obj){
      if(obj.hasOwnProperty(key)){
        if(tmp = callback(key, obj[key])){
          result += tmp;
        }
      }
    }
    return result;
  };

  start({code: 200, headers: {'Content-Type': 'freeswitch/xml'}});
  send('<?xml version="1.0" encoding="UTF-8" standalone="no" ?>' + "\\n");
  JS

  last = nil
  keys.inject(layout){|k,v| last = k[v] ||= {} }
  last[File.basename(file, '.js')] = doc
end

Makura::Model.database.save(layout)
