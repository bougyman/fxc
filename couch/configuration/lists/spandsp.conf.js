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
      <descriptors>
        {each(doc.descriptors, function(descriptor_name, tones){
          return(
            <descriptor name={descriptor_name}>
              {each(tones, function(tone_name, elements){
                return(
                  <tone name={tone_name}>
                    {each(elements, function(idx, attributes){
                      var element = <element />;
                      for(key in attributes){ element.@[key] = attributes[key]; }
                      return element;
                    })}
                  </tone>
                )})}
            </descriptor>
          )})}
      </descriptors>
    </configuration>
  </section>
</document>
  );
}
