function(doc){
  if(doc.name && !(doc.server === undefined)){
    emit([doc.name, doc.server], doc);
  }
}
