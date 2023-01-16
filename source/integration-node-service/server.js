import express from "express"
import bodyParser from "body-parser"

import api from "./api/qrcode.js"
import { connector } from "swagger-routes-express"
import swaggerUi from 'swagger-ui-express'
import swaggerJSDoc from 'swagger-jsdoc'

// Create Express erver
const expressApp = new express();
expressApp.use(bodyParser.urlencoded({ extended: false }))
expressApp.use(bodyParser.json())

// Add Swagger framework support to server
const swaggerDefinition = {
  openapi: '3.0.0',
  info: {
    title: 'QRCode API',
    version: '1.0.0',
  },
  servers: [ { url: '/api/' } ]    
};
const swaggerJSDocOptions  = {
  swaggerDefinition,
  apis: ['./api/*.js'],
};  
const apiDefinition = swaggerJSDoc(swaggerJSDocOptions );
connector(api, apiDefinition)(expressApp); // api is an export from /api/qrcode.js 
expressApp.get("/schema", (req, res) => res.json(apiDefinition));
expressApp.use('/docs', swaggerUi.serve, swaggerUi.setup(apiDefinition));

// Start server
var port = process.env.PORT || 3000;
expressApp.listen(port);
console.log("✅ App listening on port ${port}");