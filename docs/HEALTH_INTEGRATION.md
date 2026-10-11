# Health Integration

Add the following import to the application entry point:

```js
import { health, live, ready } from './src/health-handler.mjs';
```

Then register these routes before other application routes:

```js
if (p === '/api/health' && method === 'GET') return health(req, res);
if (p === '/api/health/live' && method === 'GET') return live(req, res);
if (p === '/api/health/ready' && method === 'GET') return ready(req, res);
```

Also add this dependency to `package.json`:

```json
"mssql": "^11.0.1"
```

Then install dependencies:

```bash
npm install
```

These endpoints are designed to be used for load balancers, uptime checks, and deployment health validation.
