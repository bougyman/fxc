function(head, req){
  var doc = getRow().value;

  send(
<document type="freeswitch/xml">
  <section name="configuration">
    <configuration name={doc.name} description={doc.description}>
      <settings>
        {each(doc.settings, function(name, value){
          return <param name={name} value={value} />
        })}
      </settings>
      
      <queues>
        {each(doc.queues, function(name, params){
          var xml = <queue name={name} />;
          for(key in params){
            xml.queue += <param name={key} value={params[key]} />;
          }
          return xml;
        })}
      </queues>

      <agents>
        {each(doc.agents, function(name, attributes){
          var xml = <agent name={name} />;
          for(key in attributes){ xml.@[key] = attributes[key]; }
          return xml;
        })}
      </agents>

      <tiers>
        {each(doc.tiers, function(key, tier){
          var xml = <tier level="1" position="1" />;
          for(key in tier){ xml.@[key] = tier[key]; }
          return xml;
        })}
      </tiers>
    </configuration>
  </section>
</document>
  );
}
