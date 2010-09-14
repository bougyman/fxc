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
      <cli-keybindings>
        {each(doc.keybindings, function(name, value){
          return <key name={name} value={value} />
        })}
      </cli-keybindings>
      <settings>
        {each(doc.settings, function(name, value){
          return <param name={name} value={value} />
        })}
      </settings>
    </configuration>
  </section>
</document>
  );
}
