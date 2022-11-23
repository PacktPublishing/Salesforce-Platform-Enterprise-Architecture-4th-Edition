import jsforce from "jsforce"
import pg from "pg";
const { Client } = pg;

/**
 * FormulaForce Insights Service exposed via /api/insights API
 */
export default class InsightsService {
   async get(req, res) {

      // Is FormulaForce partner logged in?
      var partnerLogin = req.session.accessToken!=null ? true : false;

      // Response shell
      var response = {
         latestResults : {
               race : "Spa",
               winner : "Hamilton" },
         championShipPrediction : {
               first : "Hamilton",
               second : "Alonso",
               third : "Vettel" }
      }

      // Query latest results from Postgres (syncronized from attached Salesforce Org via Heroku Connect)
      const client = new Client({
         connectionString: process.env.DATABASE_URL,
         ssl: { rejectUnauthorized: false }
       });
      await client.connect();
      const { rows: drivers } = await client.query(
         'SELECT salesforce.race__c.name as racename, salesforce.driver__c.name as drivername from salesforce.contestant__c ' +
            'INNER JOIN salesforce.race__c on salesforce.contestant__c.race__c=salesforce.race__c.sfid ' +
            'INNER JOIN salesforce.driver__c on salesforce.contestant__c.driver__c=salesforce.driver__c.sfid');
      if(drivers.length>0) {
         response.latestResults.race = drivers[0].racename;
         response.latestResults.winner = drivers[0].drivername;
      }

      // Query latest predictions from Postgres
      const { rows: predictions } = await client.query(
         'SELECT first, second, third, firstAccuracy, secondAccuracy, thirdAccuracy FROM raceinsights');
      if(predictions.length>0) {
         response.championShipPrediction.first = predictions[0].first;
         response.championShipPrediction.second = predictions[0].second;
         response.championShipPrediction.third = predictions[0].third;
      }
      console.log(predictions[0]);

      // Add additional response data for authenticated FormulaForce partners?
      if(partnerLogin) {
         // Partners get to see prediction accuracy
         response.championShipPrediction.firstAccuracy = '(' + predictions[0].firstaccuracy + '%)';
         response.championShipPrediction.secondAccuracy = '(' + predictions[0].secondaccuracy + '%)';
         response.championShipPrediction.thirdAccuracy = '(' + predictions[0].thirdaccuracy + '%)';
         // Retrieve Partner information from Account object
         var conn = new jsforce.Connection({
            accessToken: req.session.accessToken, 
            instanceUrl: req.session.instanceUrl });
         conn.query('select Name, FormulaForcePartnerLevel__c, FormulaForceMediaCoverage__c from Account', function(err, result) {
            if (err) {
               console.error(err);
            } else {
               // Typically Account (or other data) would be linked via lookup to the User in some way
               if(result.records.length>0) {
                  response.partnerStatus = {
                     name : result.records[0].Name,
                     level : result.records[0].FormulaForcePartnerLevel__c,
                     seasonCoverage : result.records[0].FormulaForceMediaCoverage__c }     
               }
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