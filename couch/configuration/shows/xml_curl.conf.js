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
      <bindings>
        {each(doc.bindings, function(name, binding){
          var xml = <binding name={name} />;
          for(key in binding){
            var value = binding[key];
            if(key === "gateway-url"){
              xml.binding += <param name={key} value={value.value}  bindings={value.bindings} />;
            } else {
              xml.binding += <param name={key} value={value} />;
            }
          }
          return xml;
        })}
      </bindings>
    </configuration>
  </section>
</document>
  ).toXMLString());
}
