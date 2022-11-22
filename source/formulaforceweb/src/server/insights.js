import jsforce from "jsforce"

export default class InsightsService {
   get(req, res) {
      var partnerLogin = req.session.accessToken!=null ? true : false;
      var response = {
         latestResults : {
               race : "Spa",
               winner : "Hamilton" },
         championShipPredictoin : {
               first : "",
               firstConfidence : 60,
               second : "",
               secondConfidence : 80,
               third : "",
               thirdConfidence : 12 }
      }
      // Query latest results from Postgres
      // ...
      // Query latest predictions from Postgres
      // ...
      // Get Partner information
      if(partnerLogin) {
         var conn = new jsforce.Connection({
            accessToken: req.session.accessToken, 
            instanceUrl: req.session.instanceUrl });
         conn.query('select Name from Organization', function(err, result) {
            if (err) {
               console.error(err);
            } else {
               response.latestResults.race = result.records[0].Name;
               response.partnerStatus = {
                  level : "gold",
                  seasonCoverage : 60 }  
            }
            // Send response
            res.json(response);
         });             
      } else {
         // Send response
         res.json(response);
      }
   }
}