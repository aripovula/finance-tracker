// Load test for GET /api/v1/dashboard/monthly_summary - the CQRS read model
// behind an ETag (see CLAUDE.md §3 "Why a CQRS read model"). Each iteration
// hits the endpoint twice: once with no If-None-Match (a real render), and
// once with the ETag the first response returned. The second call should
// short-circuit to a 304 - the read model hasn't changed since the first
// call, so there's nothing to re-render or re-send.
//
// The enforced thresholds are correctness-based (cache hit rate, error rate),
// not latency-based: on this small a dataset the server-side cost of a 304
// vs. a full render is only a few milliseconds, easily lost in whatever
// machine/Puma thread count this happens to run against. The clear,
// environment-independent signal is response *size* - a 304 has an empty
// body - so bytes transferred is tracked as the concrete before/after
// instead of a latency target that would be flaky on someone else's laptop.
//
// Prerequisites: `bin/rails runner loadtest/seed.rb` once, against a
// running server, to give the load-test user some real summary rows.
//
// Run with: k6 run loadtest/monthly_summary.js
// Against a non-default host: BASE_URL=https://staging.example.com k6 run ...

import http from "k6/http";
import { check } from "k6";
import { Rate, Trend } from "k6/metrics";

const BASE_URL = __ENV.BASE_URL || "http://localhost:3000";
const EMAIL = __ENV.LOADTEST_EMAIL || "loadtest@example.com";
const PASSWORD = __ENV.LOADTEST_PASSWORD || "password123";

const freshDuration = new Trend("dashboard_fresh_duration");
const cachedDuration = new Trend("dashboard_cached_duration");
const freshBytes = new Trend("dashboard_fresh_bytes");
const cachedBytes = new Trend("dashboard_cached_bytes");
const cacheHitRate = new Rate("dashboard_cache_hit_rate");

export const options = {
  scenarios: {
    dashboard_reads: {
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
    dashboard_cache_hit_rate: [ "rate>0.99" ],
  },
};

export function setup() {
  const res = http.post(
    `${BASE_URL}/api/v1/auth/login`,
    JSON.stringify({ email: EMAIL, password: PASSWORD }),
    { headers: { "Content-Type": "application/json" } }
  );

  check(res, { "setup login succeeded": (r) => r.status === 200 });

  return { accessToken: res.json("data.access_token") };
}

export default function (data) {
  const url = `${BASE_URL}/api/v1/dashboard/monthly_summary`;
  const authHeader = { Authorization: `Bearer ${data.accessToken}` };

  const fresh = http.get(url, { headers: authHeader });
  check(fresh, { "fresh request is 200": (r) => r.status === 200 });
  freshDuration.add(fresh.timings.duration);
  freshBytes.add(fresh.body ? fresh.body.length : 0);

  const etag = fresh.headers["Etag"] || fresh.headers["ETag"];

  const cached = http.get(url, {
    headers: { ...authHeader, "If-None-Match": etag },
  });
  const isCacheHit = cached.status === 304;

  check(cached, { "repeat request is 304": (r) => r.status === 304 });
  cacheHitRate.add(isCacheHit);

  if (isCacheHit) {
    cachedDuration.add(cached.timings.duration);
    cachedBytes.add(cached.body ? cached.body.length : 0);
  }
}
