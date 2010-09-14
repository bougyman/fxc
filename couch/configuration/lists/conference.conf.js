function(head, req){
  var doc = getRow().value;

  send(
<document type="freeswitch/xml">
  <section name="configuration">
    <configuration name={doc.name} description={doc.description}>
      <advertise>
        {each(doc.advertise, function(name, status){
          return <room name={name} status={status} />
        })}
      </advertise>
      <caller-controls>
        {each(doc.controls, function(name, controls){
          var xml = <group name={name} />;
          for(key in controls){
            xml.group += <control action={key} digits={controls[key]} />;
          }
          return xml;
        })}
      </caller-controls>
      <profiles>
        {each(doc.profiles, function(name, params){
          var xml = <profile name={name} />;
          for(key in params){
            xml.profile += <param name={key} value={params[key]} />;
          }
          return xml;
        })}
      </profiles>
    </configuration>
  </section>
</document>
  );
}
