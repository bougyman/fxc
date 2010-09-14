function(head, req){
  var each = function(obj, callback){
    var result = <></>;
    for(key in obj){
      if(obj.hasOwnProperty(key)){
        result += callback(key, obj[key]);
      }
    }
    return result;
  };

  var doc = getRow().value;

  start({code: 200, headers: {'Content-Type': 'freeswitch/xml'}});
  send('<?xml version="1.0" encoding="UTF-8" standalone="no" ?>' + "\n");
  send(
<document type="freeswitch/xml">
  <section name="configuration">
    <configuration name={doc.name} description={doc.description}>
      <settings>
        {each(doc.settings, function(name, value){
          return <param name={name} value={value} />
        })}
      </settings>
      
      <profiles>
        {each(doc.profiles, function(name, params){
          var xml = <profile name={name}><email /></profile>;
          for(key in params.settings){
            xml.profile += <param name={key} value={params.settings[key]} />;
          }
          for(key in params.email){
            xml.email.email += <param name={key} value={params.email[key]} />;
          }
          return xml;
        })}
      </profiles>
    </configuration>
  </section>
</document>
  );
  ;
}
