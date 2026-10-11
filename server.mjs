import http from 'node:http';
import { health, live, ready } from './src/health-handler.mjs';

const port = Number(process.env.PORT || 3000);

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url || '/', `http://${req.headers.host || 'localhost'}`);
  const p = url.pathname;

  if (req.method === 'GET') {
    if (p === '/api/health') return health(req, res);
    if (p === '/api/health/live') return live(req, res);
    if (p === '/api/health/ready') return ready(req, res);
  }

  res.writeHead(404, { 'content-type': 'application/json' });
  res.end(JSON.stringify({ error: 'Not found', path: p, method: req.method }));
});

server.listen(port, () => {
  console.log(`MoSTaa-ChaT listening on http://localhost:${port}`);
});

export default server;
