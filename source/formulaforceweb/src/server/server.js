import { createServer } from "lwr";
import session from "express-session"
import jsforce from "jsforce"
import dotenv from "dotenv";
import RaceService from "./races.js";

// Load .env configuration file
dotenv.config();
const PORT = parseInt(process.env.PORT || "3000", 10);
const SERVER_MODE = "development" === process.env.NODE_ENV ? "dev" : "prod-compat";
const {
    SALESFORCE_LOGIN_DOMAIN,
    SALESFORCE_CLIENT_ID,
    SALESFORCE_CLIENT_SECRET,
    SALESFORCE_CALLBACK_URL,
    NODE_SESSION_SECRET_KEY
} = process.env;

// Create the LWR App Server
const lwrServer = createServer({
    serverMode: SERVER_MODE,
    port: PORT,
});

// Get the internal Express server from within the LWR Server
const expressApp = lwrServer.getInternalServer("express");
  
//
// Configure express-session to store Session Id and Instance URL
//
expressApp.use(
    session({ 
        secret: NODE_SESSION_SECRET_KEY, 
        cookie: { secure: 'auto' },
        resave: false, 
        saveUninitialized: false}))

//
// OAuth2 client information can be shared with multiple connections.
//
var oauth2 = new jsforce.OAuth2({
  loginUrl : SALESFORCE_LOGIN_DOMAIN,
  clientId : SALESFORCE_CLIENT_ID,
  clientSecret : SALESFORCE_CLIENT_SECRET,
  redirectUri : SALESFORCE_CALLBACK_URL
});

//
// Get authorization url and redirect to it.
//
expressApp.get('/oauth2/auth', function(req, res) {
  res.redirect(oauth2.getAuthorizationUrl({ scope : 'api id web refresh_token' }));
});

//
// Handle oAuth callback and extract and store session token
//
expressApp.get('/oauth2/callback', function(req, res) {
    var conn = new jsforce.Connection({ oauth2 : oauth2 });
    var code = req.param('code');
    conn.authorize(code, function(err, userInfo) {
      if (err) { return console.error(err); }
      req.session.accessToken = conn.accessToken;
      req.session.instanceUrl = conn.instanceUrl;
      // Redirect to main page
      res.redirect('/');
    });
});

// Add FormulaForce API's
const raceService = new RaceService();
expressApp.get('/api/races', function(req, res) { raceService.getRaces(req, res); });

// Start the server
lwrServer
    .listen(({ port, serverMode }) => {
        console.log(`✅ App listening on port ${port} in ${serverMode} mode!`);
    })
    .catch((err) => {
        console.error(err);
        process.exit(1);
    });
