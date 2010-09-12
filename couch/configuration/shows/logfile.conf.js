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
      <profiles>
        {each(doc.profiles, function(name, profile){
          var settings = <settings />;
          for(key in profile.settings){
            settings.settings += <param name={key} value={profile.settings[key]} />;
          }

          var mappings = <mappings />;
          for(key in profile.mappings){
            mappings.mappings += <map name={key} value={profile.mappings[key]} />;
          }

          return <profile name={name}>{settings}{mappings}</profile>;
        })}
      </profiles>
    </configuration>
  </section>
</document>
  ).toXMLString());
}
