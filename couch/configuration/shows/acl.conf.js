function(doc, req){
  var each = function(obj, callback){
    var result = <></>;
    for(key in obj){
      if(obj.hasOwnProperty(key)){
        result += callback(key, obj[key]);
      }
    }
    return result;
  };

  start({code: 200, headers: {'Content-Type': 'freeswitch/xml'}});

  return(
'<?xml version="1.0" encoding="UTF-8" standalone="no" ?>' + "\n" + (
<document type="freeswitch/xml">
  <section name="configuration">
    <configuration name={doc._id} description={doc.description}>
      <network-lists>
        {each(doc.network_lists, function(name, list){
          var xml = <list name={name} default={list.default} />;
          list.nodes.forEach(function(node){
            var tag = <node />;
            for(key in node){ tag.@[key] = node[key]; }
            xml.list += tag;
          });
          return xml;
        })}
      </network-lists>
    </configuration>
  </section>
</document>
  ).toXMLString());
}
