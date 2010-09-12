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

  start({code: 200, headers: {'Content-Type': 'freeswitch/xml'}});

  send('<?xml version="1.0" encoding="UTF-8" standalone="no" ?>' + "\n");

  var sofia = getRow().value;
  log(sofia);

  var result = <document type="freeswitch/xml">
  <section name="configuration">
    <configuration name={sofia._id} description={sofia.description}>
      <global_settings>
        {each(sofia.global_settings, function(name, value){
          return <param name={name} value={value} />
        })}
      </global_settings>
      <profiles />
    </configuration>
  </section>
</document>;

  while(row = getRow()){
    var profile = row.value;
    result.section.configuration.profiles.profiles +=
    <profile name={profile.name}>
      <aliases>
        {each(profile.aliases, function(idx){
          return <alias name={profile.aliases[idx]} />
        })}
      </aliases>
      <gateways>
        {each(profile.gateways, function(name, params){
          var xml = <gateway name={gateway.name} />;
          for(var name in params){
            xml.gateway += <param name={name} value={params[name]} />;
          }
          return xml;
        })}
      </gateways>
      <domains>
        {each(profile.domains, function(name, obj){
          return <domain name={name} alias={obj.alias} parse={obj.parse} />
        })}
      </domains>
      <settings>
        {each(profile.settings, function(name, value){
          return <param name={name} value={value} />
        })}
      </settings>
    </profile>;
  }

  send(result);
}
