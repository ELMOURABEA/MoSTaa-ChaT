import { checkSqlHealth } from './db.mjs';

export async function health(req, res) {
  const started = Date.now();
  const sql = await checkSqlHealth();

  const checks = {
    application: { status: 'up' },
    sqlServer: sql,
    meta: {
      status:
        process.env.META_APP_ID && process.env.META_APP_SECRET && process.env.META_VERIFY_TOKEN
          ? 'configured'
          : 'not_configured',
    },
    whatsapp: {
      status:
        process.env.WHATSAPP_PHONE_NUMBER_ID &&
        process.env.WHATSAPP_BUSINESS_ACCOUNT_ID &&
        process.env.META_ACCESS_TOKEN
          ? 'configured'
          : 'not_configured',
    },
    billing: {
      status: process.env.STRIPE_SECRET_KEY || process.env.PAYPAL_CLIENT_ID ? 'configured' : 'not_configured',
    },
    storage: {
      status: process.env.S3_BUCKET ? 'configured' : 'not_configured',
    },
  };

  const ok = process.env.REQUIRE_SQL_HEALTH !== 'true' || sql.status === 'up';

  const payload = {
    status: ok ? 'healthy' : 'unhealthy',
    service: 'MoSTaa-ChaT',
    version: process.env.APP_VERSION || '0.3.0',
    environment: process.env.NODE_ENV || 'development',
    timestamp: new Date().toISOString(),
    uptimeSeconds: Math.round(process.uptime()),
    responseTimeMs: Date.now() - started,
    checks,
  };

  res.writeHead(ok ? 200 : 503, { 'content-type': 'application/json' });
  res.end(JSON.stringify(payload));
}

export const live = (req, res) => {
  res.writeHead(200, { 'content-type': 'application/json' });
  res.end(
    JSON.stringify({
      status: 'alive',
      timestamp: new Date().toISOString(),
      uptimeSeconds: Math.round(process.uptime()),
    })
  );
};

export async function ready(req, res) {
  const sql = await checkSqlHealth();
  const ok = process.env.REQUIRE_SQL_HEALTH !== 'true' || sql.status === 'up';

  res.writeHead(ok ? 200 : 503, { 'content-type': 'application/json' });
  res.end(JSON.stringify({ status: ok ? 'ready' : 'not_ready', checks: { sqlServer: sql } }));
}
