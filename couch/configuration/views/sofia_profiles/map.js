function(doc){
  if(doc.aliases && doc.gateways && doc.domains && doc.settings){
    emit([doc.server, 1], doc);
  }
  if(doc._id === "sofia.conf"){
    emit([doc.server, 0], doc);
  }
}
