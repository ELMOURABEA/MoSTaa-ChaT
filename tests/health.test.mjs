import test from 'node:test';
import assert from 'node:assert/strict';
import { health, live, ready } from '../src/health-handler.mjs';

function makeRes() {
  return {
    statusCode: null,
    body: null,
    headers: null,
    writeHead(code, headers) {
      this.statusCode = code;
      this.headers = headers;
      return this;
    },
    end(payload) {
      this.body = payload;
    },
  };
}

test('GET /api/health returns a health payload', async () => {
  const res = makeRes();
  await health({}, res);

  assert.equal(res.statusCode, 200);
  const payload = JSON.parse(res.body);
  assert.equal(payload.service, 'MoSTaa-ChaT');
  assert.ok(['healthy', 'unhealthy'].includes(payload.status));
});

test('GET /api/health/live returns alive payload', async () => {
  const res = makeRes();
  live({}, res);

  assert.equal(res.statusCode, 200);
  const payload = JSON.parse(res.body);
  assert.equal(payload.status, 'alive');
});

test('GET /api/health/ready returns readiness state', async () => {
  const res = makeRes();
  await ready({}, res);

  assert.ok([200, 503].includes(res.statusCode));
  const payload = JSON.parse(res.body);
  assert.ok(['ready', 'not_ready'].includes(payload.status));
});
