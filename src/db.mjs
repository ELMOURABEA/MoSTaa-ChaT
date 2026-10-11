let poolPromise;

export const sqlConfigured = () => Boolean(
  process.env.SQLSERVER_HOST &&
  process.env.SQLSERVER_DATABASE &&
  process.env.SQLSERVER_USERNAME &&
  process.env.SQLSERVER_PASSWORD
);

const config = () => ({
  server: process.env.SQLSERVER_HOST,
  port: Number(process.env.SQLSERVER_PORT || 1433),
  database: process.env.SQLSERVER_DATABASE,
  user: process.env.SQLSERVER_USERNAME,
  password: process.env.SQLSERVER_PASSWORD,
  options: {
    encrypt: process.env.SQLSERVER_ENCRYPT !== 'false',
    trustServerCertificate: process.env.SQLSERVER_TRUST_SERVER_CERTIFICATE === 'true',
    enableArithAbort: true,
  },
  pool: {
    min: Number(process.env.SQLSERVER_POOL_MIN || 0),
    max: Number(process.env.SQLSERVER_POOL_MAX || 10),
    idleTimeoutMillis: Number(process.env.SQLSERVER_POOL_IDLE_MS || 30000),
  },
  connectionTimeout: Number(process.env.SQLSERVER_CONNECTION_TIMEOUT_MS || 10000),
  requestTimeout: Number(process.env.SQLSERVER_REQUEST_TIMEOUT_MS || 15000),
});

export async function getPool() {
  if (!sqlConfigured()) throw Error('SQL Server not configured');

  if (!poolPromise) {
    poolPromise = import('mssql')
      .then(({ default: sql }) => new sql.ConnectionPool(config()).connect())
      .catch((e) => {
        poolPromise = undefined;
        throw e;
      });
  }

  return poolPromise;
}

export async function checkSqlHealth() {
  const started = Date.now();

  if (!sqlConfigured()) {
    return { status: 'not_configured', latencyMs: 0 };
  }

  try {
    const pool = await getPool();
    const r = await pool.request().query(
      "SELECT DB_NAME() database_name,@@SERVERNAME server_name,CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(128)) product_version,SYSUTCDATETIME() server_utc"
    );

    return {
      status: 'up',
      latencyMs: Date.now() - started,
      ...r.recordset[0],
    };
  } catch (e) {
    return {
      status: 'down',
      latencyMs: Date.now() - started,
      error: process.env.NODE_ENV === 'production' ? 'SQL connection failed' : e.message,
    };
  }
}
