function(head, req){
  var doc = getRow().value;

  send(
<document type="freeswitch/xml">
  <section name="configuration">
    <configuration name={doc.name} description={doc.description}>
      <network-lists>
        {each(doc.network_lists, function(name, list){
          var xml = <list name={name} default={list.default} />;
          list.nodes.forEach(function(node){
            var tag = <node />;
            for(key in node){ tag.@[key] = node[key]; }
            xml.list += tag;
          });
          return xml;
        })}
      </network-lists>
    </configuration>
  </section>
</document>
  );
}
