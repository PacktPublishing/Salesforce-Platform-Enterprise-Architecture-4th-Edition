import jsforce from "jsforce"

export default class RaceService {
   getRaces(req, res) {
      // Connect and output query results
      var conn = new jsforce.Connection({accessToken: req.session.accessToken, instanceUrl: req.session.instanceUrl });
      conn.query('select Name from Organization', function(err, result) {
         if (err) {
            console.error(err);
            res.send('{ "summary" : "Error" }');
         } else {
            res.send('{ "summary" : "Org Name is ' + result.records[0].Name + '" }');
         }
      }); 
   }
}