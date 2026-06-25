-- =========================================================
-- 02_traffic_analysis.sql
-- Question: Which acquisition channel actually converts better —
-- Pinterest (search intent) or Facebook (interruption-based)?
-- This validates the deck's "Intent vs. Interruption" slide using
-- the underlying daily traffic data, not just the headline stat.
-- =========================================================

-- 2.1 Overall conversion rate by channel (GROUP BY + aggregation)
SELECT
    channel,
    SUM(visits)        AS total_visits,
    SUM(conversions)   AS total_conversions,
    ROUND(100.0 * SUM(conversions) / SUM(visits), 2) AS conversion_rate_pct
FROM marketing_traffic
GROUP BY channel
ORDER BY conversion_rate_pct DESC;

-- 2.2 Monthly trend per channel — is Pinterest's advantage consistent
-- over time, or a one-off spike? (GROUP BY with date truncation)
SELECT
    strftime('%Y-%m', traffic_date) AS month,
    channel,
    SUM(visits)        AS visits,
    SUM(conversions)   AS conversions,
    ROUND(100.0 * SUM(conversions) / SUM(visits), 2) AS conversion_rate_pct
FROM marketing_traffic
GROUP BY month, channel
ORDER BY month, channel;

-- 2.3 Best and worst single days for each channel (subquery)
-- Useful to flag anomalies — was there a day where Facebook
-- outperformed its average, worth investigating?
SELECT
    channel,
    traffic_date,
    conversions,
    visits,
    ROUND(100.0 * conversions / visits, 2) AS day_conversion_rate_pct
FROM marketing_traffic mt
WHERE conversions = (
    SELECT MAX(conversions)
    FROM marketing_traffic mt2
    WHERE mt2.channel = mt.channel
)
ORDER BY channel;
