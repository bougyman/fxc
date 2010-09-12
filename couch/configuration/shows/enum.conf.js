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
      <settings>
        {each(doc.settings, function(name, value){
          return <param name={name} value={value} />
        })}
      </settings>
      <routes>
        {each(doc.routes, function(name, route){
          var xml = <route />;
          for(key in route){ xml.@[key] = route[key]; }
          return xml;
        })}
      </routes>
    </configuration>
  </section>
</document>
  ).toXMLString());
}
