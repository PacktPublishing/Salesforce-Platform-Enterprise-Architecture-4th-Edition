import pg from "pg";
import dotenv from "dotenv";
const { Client } = pg;

// Read DATABASE_URL from environment (.env file) and connect to Postgres
dotenv.config();
const client = new Client({
    connectionString: process.env.DATABASE_URL,
    ssl: { rejectUnauthorized: false }
  });
await client.connect();

// Create raceinsights table with some examples insights in it
await client.query('DROP TABLE IF EXISTS raceinsights');
await client.query('CREATE TABLE raceinsights (' +
    'first varchar(32), ' +
    'firstaccuracy int, ' +
    'second varchar(32), ' +
    'secondaccuracy int, ' +
    'third varchar(32), ' +
    'thirdaccuracy int)');
await client.query('INSERT INTO raceinsights ' +
    '(first, firstaccuracy, second, secondaccuracy, third, thirdaccuracy) ' +
    'VALUES (\'Lewis Hamilton\', 60, \'Alonso\', 44, \'Vettel\', 30)');

// Disconnect 
await client.end();

console.log('Successfully inserted predictions into your Postgres database!');