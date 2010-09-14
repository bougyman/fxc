function(head, req){
  var doc = getRow().value;
  log(doc);

  send(
<document type="freeswitch/xml">
  <section name="configuration">
    <configuration name={doc.name} description={doc.description}>
      <settings>
        {each(doc.settings, function(name, value){
          return <param name={name} value={value} />
        })}
      </settings>
      
      <fifos>
        {each(doc.fifos, function(name, fifo){
          var xml = <fifo name={name} importance={fifo.importance} />;

          for(key in fifo){
            var value = fifo[key];

            if(key === "members"){
              xml.fifo += each(value, function(mname, member){
                var mxml = <member>{mname}</member>;
                for(mkey in member){ mxml.@[mkey] = member[mkey]; }
                return mxml;
              });
            } else {
              xml.@[key] = value;
            }
          }
          return xml;
        })}
      </fifos>
    </configuration>
  </section>
</document>
  );
}
