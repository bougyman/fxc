function(head, req){
  var doc = getRow().value;

  send(
<document type="freeswitch/xml">
  <section name="configuration">
    <configuration name={doc.name} description={doc.description}>
      {each(doc.directories, function(name, directory){
        return(
          <directory name={name} path={directory.path}>
            {each(directory, function(key, value){
              if(!(key === "path")){
                return <param name={key} value={value} />;
              }
            })}
          </directory>
          )
      })}
    </configuration>
  </section>
</document>
  );
}
