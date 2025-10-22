const fs = require("fs");
const path = require("path");
const pkgUp = require("pkg-up");
const { backendDir } = require("./dist/backend/src/paths");
const { env } = require("./dist/backend/src/env");

const moment = require("moment-timezone");
moment.tz.setDefault("UTC");

const entities = path.relative(process.cwd(), path.resolve(backendDir, "dist/backend/src/data/entities/*.js"));
const migrations = path.relative(process.cwd(), path.resolve(backendDir, "dist/backend/src/migrations/*.js"));
const migrationsDir = path.relative(process.cwd(), path.resolve(backendDir, "src/migrations"));

// Parse DATABASE_URL for Postgres connection
const databaseUrl = process.env.DATABASE_URL || env.DATABASE_URL;
let dbConfig = {};

if (databaseUrl) {
  // Use DATABASE_URL (Postgres format)
  dbConfig = {
    type: "postgres",
    url: databaseUrl,
    ssl: process.env.PGSSLMODE === "require" ? { rejectUnauthorized: false } : false,
  };
} else {
  // Fallback to individual MySQL env vars (legacy)
  dbConfig = {
    type: "mysql",
    host: env.DB_HOST,
    port: env.DB_PORT,
    username: env.DB_USER,
    password: env.DB_PASSWORD,
    database: env.DB_DATABASE,
    charset: "utf8mb4",
    supportBigNumbers: true,
    bigNumberStrings: true,
    dateStrings: true,
    connectTimeout: 2000,
    extra: {
      typeCast(field, next) {
        if (field.type === "DATETIME") {
          const val = field.string();
          return val != null ? moment.utc(val).format("YYYY-MM-DD HH:mm:ss") : null;
        }
        return next();
      },
    },
  };
}

module.exports = {
  ...dbConfig,
  synchronize: false,
  logging: ["error", "warn"],
  
  // Entities
  entities: [entities],

  // Migrations
  migrations: [migrations],
  cli: {
    migrationsDir,
  },
};