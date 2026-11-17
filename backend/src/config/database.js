const { Pool } = require("pg");
const fs = require("fs");
const path = require("path");

require("dotenv").config();

const caPath = path.resolve(
  __dirname,
  "../../",
  process.env.DB_CA_PATH
);

const pool = new Pool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT),
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  ssl: {
    rejectUnauthorized: true,
    ca: fs.readFileSync(caPath, "utf8")
  }
});

module.exports = pool;
