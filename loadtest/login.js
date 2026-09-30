// Load test for POST /api/v1/auth/login. Unlike the dashboard script, this
// isn't testing a cache - it's a genuine capacity question: has_secure_password
// runs a real bcrypt hash comparison on every login, which is deliberately
// CPU-expensive (that's the point of bcrypt), so it directly caps how many
// logins/sec this app can sustain. There's no caching or consistency
// mechanism to add here; the cost is inherent to the endpoint.
//
// Thresholds are error-rate only, not latency - bcrypt's wall-clock cost
// depends on the CPU it runs on, so a fixed millisecond target would be
// flaky on a different machine. Watch dashboard_login_duration in the
// summary output to see how latency actually moves as concurrency ramps up.
//
// Self-contained: setup() registers a fixed test account once (idempotent -
// 201 the first run against a given database, 422 "already taken" on every
// run after, either way the account exists). No seed script needed, unlike
// bin/loadtest for monthly_summary.js.
//
// Run with: k6 run loadtest/login.js
// Against a non-default host: BASE_URL=https://staging.example.com k6 run ...

import http from "k6/http";
import { check } from "k6";

const BASE_URL = __ENV.BASE_URL || "http://localhost:3000";
const EMAIL = __ENV.LOADTEST_EMAIL || "loadtest-login@example.com";
const PASSWORD = __ENV.LOADTEST_PASSWORD || "password123";

export const options = {
  scenarios: {
    login_attempts: {
      executor: "ramping-vus",
      startVUs: 0,
      stages: [
        { duration: "10s", target: 10 },
        { duration: "15s", target: 10 },
        { duration: "5s", target: 0 },
      ],
    },
  },
  thresholds: {
    http_req_failed: [ "rate<0.01" ],
  },
};

export function setup() {
  http.post(
    `${BASE_URL}/api/v1/auth/register`,
    JSON.stringify({ email: EMAIL, password: PASSWORD, password_confirmation: PASSWORD }),
    { headers: { "Content-Type": "application/json" } }
  );
}

export default function () {
  const res = http.post(
    `${BASE_URL}/api/v1/auth/login`,
    JSON.stringify({ email: EMAIL, password: PASSWORD }),
    { headers: { "Content-Type": "application/json" } }
  );

  check(res, {
    "login is 200": (r) => r.status === 200,
    "returns an access token": (r) => !!r.json("data.access_token"),
  });
}
