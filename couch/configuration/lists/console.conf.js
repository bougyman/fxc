function(head, req){
  var doc = getRow().value;

  send(
<document type="freeswitch/xml">
  <section name="configuration">
    <configuration name={doc.name} description={doc.description}>
      <mappings>
        {each(doc.mappings, function(name, value){
          return <map name={name} value={value.join(',')} />
        })}
      </mappings>
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
