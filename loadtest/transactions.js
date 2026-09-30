// Load test for GET /api/v1/transactions under many *distinct*, concurrently
// authenticated users - each fetching a transaction list unique to them.
// The point isn't just "no 500s under load" - it's proving per-user data
// isolation holds while many requests are in flight at once: every VU
// checks that what comes back is actually *its own* user's data, not
// merely a 200.
//
// Each VU is assigned one pre-seeded user's JWT, minted directly by
// loadtest/seed_transaction_users.rb - bypassing login's bcrypt cost
// entirely, since that's a separate concern already covered by
// loadtest/login.js. This script is purely about the transactions read
// path itself.
//
// Run with:
//   bin/rails runner loadtest/seed_transaction_users.rb   (once, or whenever
//                                                           tmp/loadtest_transaction_users.json is missing)
//   k6 run loadtest/transactions.js
// Or just: bin/loadtest-transactions
//
// LOADTEST_USER_COUNT (default 20) controls how many distinct users get
// seeded and, correspondingly, how many concurrent VUs this ramps to - set
// it the same way before running the seed script if you want a different
// concurrency level.

import http from "k6/http";
import { check } from "k6";
import { SharedArray } from "k6/data";

const BASE_URL = __ENV.BASE_URL || "http://localhost:3000";

const users = new SharedArray("loadtest transaction users", function () {
  return JSON.parse(open("../tmp/loadtest_transaction_users.json"));
});

export const options = {
  scenarios: {
    per_user_transactions: {
      executor: "ramping-vus",
      startVUs: 0,
      stages: [
        { duration: "10s", target: users.length },
        { duration: "20s", target: users.length },
        { duration: "5s", target: 0 },
      ],
    },
  },
  thresholds: {
    http_req_failed: [ "rate<0.01" ],
    checks: [ "rate>0.99" ],
  },
};

export default function () {
  const user = users[(__VU - 1) % users.length];

  const res = http.get(`${BASE_URL}/api/v1/transactions`, {
    headers: { Authorization: `Bearer ${user.token}` },
  });

  check(res, {
    "status is 200": (r) => r.status === 200,
    "returns exactly this user's own transactions": (r) => {
      const data = r.json("data");
      return (
        Array.isArray(data) &&
        data.length === user.transaction_count &&
        data.every((txn) => txn.bank_account_id === user.bank_account_id)
      );
    },
  });
}
