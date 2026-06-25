# Gut2Good — US Market Expansion: SQL Data Analysis

A SQL-based analysis of e-commerce sales, marketing traffic, and data-quality
patterns, built around the real US market expansion strategy for **Gut2Good**
(gut-health digital products, scaling from Vietnam to the US market).

This project simulates a realistic transactional dataset calibrated against
the actual business strategy deck (conversion rates, revenue mix, traffic
channels) and answers the same questions a Data Analyst would be asked to
answer for this business in production.

## Why this project exists

I run Gut2Good's e-commerce operations myself — auditing transactions,
flagging anomalies, and managing catalog data day to day, mostly in Excel
and Shopify Flow. This project is me formalizing that same analytical habit
in SQL: pulling structured business questions out of a real strategy
document and answering them with queries instead of manual spreadsheet
sorting.

The dataset is **simulated** (no real customer data is used or exposed),
but it is built to match the actual numbers from the company's market
expansion deck — see `docs/source_context.md` for the original figures.

## Business questions this answers

1. **Does Pinterest actually outperform Facebook on conversion**, or was
   that a single lucky data point in the deck? → `sql/02_traffic_analysis.sql`
2. **Does real order data match the planned 60/30/10 revenue split**
   across products? → `sql/03_revenue_analysis.sql`
3. **Which acquisition channel brings the highest-value customers**, not
   just the most signups? → `sql/03_revenue_analysis.sql`
4. **How much revenue is at risk from refunds and duplicate orders**, and
   can it be caught before it happens? → `sql/04_data_quality_audit.sql`

## Tech used

- SQL (SQLite dialect — runs anywhere, no server setup needed)
- Python (data generation only — `generate_data.py`, `build_db.py`)
- Core SQL techniques: `GROUP BY` aggregation, correlated subqueries,
  `HAVING` filters, window functions (`SUM() OVER`, `RANK() OVER`),
  multi-table joins, referential integrity checks

## Repo structure

```
gut2good-sql-analysis/
├── data/
│   ├── products.csv
│   ├── customers.csv
│   ├── orders.csv
│   ├── order_items.csv
│   ├── marketing_traffic.csv
│   └── gut2good.db          ← ready-to-query SQLite database
├── sql/
│   ├── 01_schema.sql         ← table definitions
│   ├── 02_traffic_analysis.sql
│   ├── 03_revenue_analysis.sql
│   └── 04_data_quality_audit.sql
├── docs/
│   ├── findings.md           ← results + business interpretation
│   └── source_context.md     ← the real deck figures this was built from
├── generate_data.py          ← reproducible simulated dataset
├── build_db.py                ← builds gut2good.db from the CSVs
└── README.md
```

## How to run it

No server, no install needed beyond Python's built-in `sqlite3`.

```bash
# Rebuild the dataset from scratch (optional — gut2good.db is already included)
python3 generate_data.py
python3 build_db.py

# Run any query file
python3 -c "
import sqlite3
conn = sqlite3.connect('data/gut2good.db')
cur = conn.cursor()
cur.execute(open('sql/02_traffic_analysis.sql').read().split(';')[0])
print(cur.fetchall())
"
```

Or open `data/gut2good.db` directly in any SQLite browser (e.g. DB Browser
for SQLite, TablePlus, or the SQLite VS Code extension).

## Key findings

See [`docs/findings.md`](docs/findings.md) for the full write-up. Headline
result: the simulated data reproduces the deck's claimed conversion gap
almost exactly — **2.21% (Pinterest) vs 1.18% (Facebook)** — which validates
that the "search intent beats interruption" strategy holds up against
day-by-day data, not just a single aggregate stat.

---
*Built by Adrian Povestca as a portfolio project demonstrating SQL analysis
applied to a real business context.*
