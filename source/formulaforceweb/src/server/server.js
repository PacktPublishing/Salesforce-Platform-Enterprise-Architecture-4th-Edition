import { createServer } from "lwr";
import { connector } from "swagger-routes-express"
import swaggerUi from 'swagger-ui-express'
import swaggerJSDoc from 'swagger-jsdoc'
import session from "express-session"
import jsforce from "jsforce"
import dotenv from "dotenv";
import api from "./api/insights.js"

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
  
// Configure express-session to store Session Id and Instance URL
if(NODE_SESSION_SECRET_KEY) {
    expressApp.use(
        session({ 
            secret: NODE_SESSION_SECRET_KEY, 
            cookie: { secure: 'auto' },
            resave: false, 
            saveUninitialized: false}))    
}

// OAuth2 client information can be shared with multiple connections.
var oauth2 = new jsforce.OAuth2({
  loginUrl : SALESFORCE_LOGIN_DOMAIN,
  clientId : SALESFORCE_CLIENT_ID,
  clientSecret : SALESFORCE_CLIENT_SECRET,
  redirectUri : SALESFORCE_CALLBACK_URL
});

// Get authorization url and redirect to it.
expressApp.get('/oauth2/auth', function(req, res) {
  res.redirect(oauth2.getAuthorizationUrl({ scope : 'api id web refresh_token' }));
});

// Handle oAuth callback and extract and store session token
expressApp.get('/oauth2/callback', function(req, res) {
    var conn = new jsforce.Connection({ oauth2 : oauth2 });
    var code = req.query['code'];
    conn.authorize(code, function(err, userInfo) {
      if (err) { return console.error(err); }
      req.session.accessToken = conn.accessToken;
      req.session.instanceUrl = conn.instanceUrl;
      // Redirect to main page
      res.redirect('/');
    });
});

// Handle oAuth logout
expressApp.get('/oauth2/logout', function(req, res) {
    var conn = new jsforce.Connection({
        oauth2 : oauth2,
        accessToken: req.session.accessToken, 
        instanceUrl: req.session.instanceUrl });
    conn.logout((error) => {
        if (error) {
            console.error('Failed to revoke authentication token: ' + error);
            res.status(500).json(error);
        } else {
            req.session.destroy((err) => {
                if (err) {
                    console.error('Failed to destroy server session: ' + err);
                    res.status(500).send('Failed to destroy server session');
                } else {
                    res.redirect('/');
                }
            });
        }
    });
});

// Add APIs
const swaggerDefinition = {
    openapi: '3.0.0',
    info: {
      title: 'FormulaForce API',
      version: '1.0.0',
    },
    servers: [ { url: '/api/' } ]    
  };
const swaggerJSDocOptions  = {
    swaggerDefinition,
    apis: ['./src/server/api/*.js'],
};  
const apiDefinition = swaggerJSDoc(swaggerJSDocOptions );
connector(api, apiDefinition)(expressApp); // api is an export from /api/insight.js 
expressApp.get("/api-docs/swagger.json", (req, res) => res.json(apiDefinition));
expressApp.use('/api-docs', swaggerUi.serve, swaggerUi.setup(apiDefinition));

// Start the server
lwrServer
    .listen(({ port, serverMode }) => {
        console.log(`✅ App listening on port ${port} in ${serverMode} mode!`);
    })
    .catch((err) => {
        console.error(err);
        process.exit(1);
    });
