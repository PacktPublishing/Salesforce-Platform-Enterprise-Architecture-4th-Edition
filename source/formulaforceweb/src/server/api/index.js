import jsforce from "jsforce"
import pg from "pg";
const { Client } = pg;

// GET /api/insights API
const insights = async function (req, res) {

   // Response
   var response = {};

   // Is a FormulaForce partner authenticated?
   var partnerAuth = req.session.accessToken!=null ? true : false;

   // Query latest race results from Postgres (syncronized from attached Salesforce Org via Heroku Connect)
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
      response.latestResults = {};
      response.latestResults.race = drivers[0].racename;
      response.latestResults.winner = drivers[0].drivername;
   }

   // Query latest predictions from Postgres
   const { rows: predictions } = await client.query(
      'SELECT first, second, third, firstAccuracy, secondAccuracy, thirdAccuracy FROM raceinsights');
   if(predictions.length>0) {
      response.championShipPrediction = {};
      response.championShipPrediction.first = predictions[0].first;
      response.championShipPrediction.second = predictions[0].second;
      response.championShipPrediction.third = predictions[0].third;
   }

   // Add additional response data for authenticated FormulaForce partners?
   if(partnerAuth) {
      // Partners get to see prediction accuracy
      response.championShipPrediction.firstAccuracy = '(' + predictions[0].firstaccuracy + '%)';
      response.championShipPrediction.secondAccuracy = '(' + predictions[0].secondaccuracy + '%)';
      response.championShipPrediction.thirdAccuracy = '(' + predictions[0].thirdaccuracy + '%)';
      // Retrieve Partner information from Account object
      var conn = new jsforce.Connection({
         accessToken: req.session.accessToken, 
         instanceUrl: req.session.instanceUrl });
      var result = await conn.query('select Name, FormulaForcePartnerLevel__c, FormulaForceMediaCoverage__c from Account');
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
}

export default { insights }