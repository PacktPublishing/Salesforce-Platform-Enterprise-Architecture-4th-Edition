import { createServer } from "lwr";
import RaceService from "./races.js";

const PORT = parseInt(process.env.PORT || "3001", 10);
const SERVER_MODE = "development" === process.env.NODE_ENV ? "dev" : "prod-compat";

// Create the LWR App Server
const lwrServer = createServer({
    serverMode: SERVER_MODE,
    port: PORT,
});

// Get the internal express app
const expressApp = lwrServer.getInternalServer("express");

// Add API's
const raceService = new RaceService();
expressApp.get('/api/races', function(req, res) { raceService.getRaces(req, res); });
  
// Start the server
lwrServer
    .listen(({ port, serverMode }) => {
        console.log(`✅ App listening on port ${port} in ${serverMode} mode!`);
        console.log(`Url http://localhost:${port}`);
    })
    .catch((err) => {
        console.error(err);
        process.exit(1);
    });
