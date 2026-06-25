# Findings — Gut2Good US Market Expansion Analysis

Results from running `sql/02_traffic_analysis.sql`, `sql/03_revenue_analysis.sql`,
and `sql/04_data_quality_audit.sql` against the simulated dataset.

## 1. Traffic: Pinterest vs. Facebook conversion

| Channel   | Total Visits | Conversions | Conversion Rate |
|-----------|--------------|-------------|------------------|
| Pinterest | 24,137       | 533         | **2.21%**        |
| Facebook  | 43,284       | 511         | **1.18%**        |

**Interpretation:** The deck's claim — that Pinterest's search-intent traffic
converts nearly 2x better than Facebook's interruption-based traffic — holds
up when checked against simulated day-by-day data, not just a single
aggregate number. Facebook still drives more raw visits (43k vs 24k), but
Pinterest delivers almost the same number of actual conversions (533 vs 511)
from roughly half the traffic volume.

**Business implication:** if ad spend is being allocated by visit volume
rather than conversion efficiency, Facebook is likely over-funded relative
to its actual output. This supports the deck's Phase 2 plan to lean further
into the "Pinterest Engine."

## 2. Revenue mix vs. plan

| Category      | Actual Revenue | Actual Share | Planned Share (deck) |
|----------------|-----------------|---------------|------------------------|
| Reset Guide    | $16,848         | 50.6%         | 60%                    |
| Upsell         | $8,789          | 26.4%         | 10%                    |
| Recipe Guide   | $7,695          | 23.1%         | 30%                    |

**Interpretation:** Upsells are overperforming their planned 10% share by a
wide margin (26.4% actual vs. 10% planned), while the core Reset Guide is
underperforming its 60% target. This is a simulated dataset, so the gap
itself isn't a real finding — but the *query pattern* is exactly what a
Data Analyst would run monthly to catch plan-vs-actual drift early, before
it affects the revenue forecast leadership is using for the Phase 4 scaling
decision.

## 3. Revenue by acquisition channel

| Channel    | Orders | Revenue  | Avg Order Value |
|------------|--------|----------|------------------|
| Pinterest  | 523    | $16,067  | $30.72           |
| Facebook   | 323    | $10,112  | $31.31           |
| Organic    | 179    | $5,152   | $28.78           |
| Referral   | 65     | $2,001   | $30.78           |

**Interpretation:** Average order value is fairly consistent across
channels (~$29–31), which means the conversion-rate gap from section 1 is
the real lever here — not basket size. Pinterest's traffic efficiency
translates directly into being the top revenue-generating channel, even
with fewer total visits than Facebook.

## 4. Data quality audit

| Order Status | Count | % of Total |
|----------------|--------|--------------|
| Completed      | 1,090  | 89.4%        |
| Refunded       | 92     | 7.6%         |
| Duplicate      | 37     | 3.0%         |

**Interpretation:** About 1 in 10 orders is either refunded or flagged as a
duplicate. In a real production system, this is the kind of pattern that
justifies building an automated flag (e.g. a Shopify Flow rule) rather than
catching it manually after the fact — the same logic described in the
"Rule-based prevention" approach from my e-commerce auditing work.

The orphan-order check (orders with no matching line items) returned zero
rows in this dataset, confirming referential integrity between `orders` and
`order_items` — a basic but necessary sanity check before trusting any
revenue number above it.

## Limitations

- This is a **simulated** dataset calibrated to be consistent with the
  original deck's headline figures — it is not real Gut2Good transaction
  data, and the specific revenue-mix gap in section 2 is an artifact of the
  random generation, not a real business finding.
- The goal of this project is to demonstrate SQL technique (joins,
  subqueries, window functions, `GROUP BY`/`HAVING` audits) applied to a
  realistic business structure, not to publish real financials.
