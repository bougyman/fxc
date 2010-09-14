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
      <routes>
        {each(doc.routes, function(name, route){
          var xml = <route />;
          for(key in route){ xml.@[key] = route[key]; }
          return xml;
        })}
      </routes>
    </configuration>
  </section>
</document>
  );
}
