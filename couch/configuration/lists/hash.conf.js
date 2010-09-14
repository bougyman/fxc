function(head, req){
  var doc = getRow().value;

  send(
<document type="freeswitch/xml">
  <section name="configuration">
    <configuration name={doc.name} description={doc.description}>
      <remotes>
        {each(doc.remotes, function(name, attributes){
          var xml = <remote name={name} />;
          for(key in attributes){ xml.@[key] = attributes[key]; }
          return xml;
        })}
      </remotes>
    </configuration>
  </section>
</document>
  );
}
