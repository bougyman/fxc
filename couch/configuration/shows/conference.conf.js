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
      <advertise>
        {each(doc.advertise, function(name, status){
          return <room name={name} status={status} />
        })}
      </advertise>
      <caller-controls>
        {each(doc.controls, function(name, controls){
          var xml = <group name={name} />;
          for(key in controls){
            xml.group += <control action={key} digits={controls[key]} />;
          }
          return xml;
        })}
      </caller-controls>
      <profiles>
        {each(doc.profiles, function(name, params){
          var xml = <profile name={name} />;
          for(key in params){
            xml.profile += <param name={key} value={params[key]} />;
          }
          return xml;
        })}
      </profiles>
    </configuration>
  </section>
</document>
  ).toXMLString());
}
