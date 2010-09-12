function(doc, req){
  var key;
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
      <global_settings>
        {each(doc.settings, function(name, value){
          return <param name={name} value={value} />
        })}
      </global_settings>
  

      <profiles>
        {each(lookup_profiles?, function(profile){
        <profile name={profile.name}>
          <aliases>
            {each(profile.aliases, function(name){
              return <alias name={name} />
            })}
          </aliases>
          <gateways>
            {each(profile.gateways, function(name, params){
              <gateway name={gateway.name}>
              {each(params), function(name, value){
                return <param name={name} value={value} />
              })}
              </gateway>
            })}
          </gateways>
          <domains>
            {each(profile.domains, function(name, alias, parse){
              return <domain name={name} alias={alias} parse={parse} />
            })}
          </domains>
          <settings>
            {each(profile.settings, function(name, value){
              return <param name={name} value={value} />
            })}
          </settings>

        </profile>
        })}
      </profiles>

    </configuration>
  </section>
</document>
  ).toXMLString());
}
