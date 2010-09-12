function(head, req){
  var each = function(obj, callback){
    var result = <></>;
    for(key in obj){
      if(obj.hasOwnProperty(key)){
        result += callback(key, obj[key]);
      }
    }
    return result;
  };

  start({code: 200, headers: {'Content-Type': 'freeswitch/xml'}});
  send('<?xml version="1.0" encoding="UTF-8" standalone="no" ?>' + "\n");

  log(head);
}
