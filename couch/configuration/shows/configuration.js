function(doc, req) {
  log(req);

  var name = encodeURIComponent(req.form.key_value);
  var url

  if(name === "sofia.conf"){
    var host = req.form.hostname
    var url = "/fxc/_design/configuration/_list/sofia/sofia_profiles" +
      "?startkey=" + encodeURIComponent('["' + host + '",0]') +
      "&endkey="   + encodeURIComponent('["' + host + '",1]');
  } else {
    var url = "/fxc/_design/configuration/_list/" + name + "/conf";
  }

  return {code: 302, body: '', headers: {'Location': url}}
}
