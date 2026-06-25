-- =========================================================
-- 03_revenue_analysis.sql
-- Question: Does actual order data match the deck's revenue
-- forecast (60% Reset Guide / 30% Recipe Guide / 10% Upsell)?
-- =========================================================

-- 3.1 Revenue contribution by product category (GROUP BY + share calculation)
-- Only counts 'completed' orders — refunded/duplicate orders are
-- excluded from revenue, but tracked separately in 04_data_quality.sql
SELECT
    p.category,
    SUM(oi.quantity * oi.unit_price_usd) AS revenue_usd,
    ROUND(
        100.0 * SUM(oi.quantity * oi.unit_price_usd) /
        (SELECT SUM(oi2.quantity * oi2.unit_price_usd)
         FROM order_items oi2
         JOIN orders o2 ON o2.order_id = oi2.order_id
         WHERE o2.order_status = 'completed'),
    2) AS revenue_share_pct
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.order_status = 'completed'
GROUP BY p.category
ORDER BY revenue_usd DESC;

-- 3.2 Revenue by acquisition channel — which channel brings
-- the highest-value customers, not just the most conversions?
SELECT
    c.acquisition_channel,
    COUNT(DISTINCT o.order_id)              AS total_orders,
    SUM(oi.quantity * oi.unit_price_usd)    AS revenue_usd,
    ROUND(
        SUM(oi.quantity * oi.unit_price_usd) / COUNT(DISTINCT o.order_id),
    2) AS avg_order_value_usd
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'completed'
GROUP BY c.acquisition_channel
ORDER BY revenue_usd DESC;

-- 3.3 Running cumulative revenue over time (window function)
-- Shows growth trajectory — useful for the deck's "Roadmap to Scaling" slide
SELECT
    order_date,
    daily_revenue_usd,
    SUM(daily_revenue_usd) OVER (ORDER BY order_date) AS cumulative_revenue_usd
FROM (
    SELECT
        o.order_date,
        SUM(oi.quantity * oi.unit_price_usd) AS daily_revenue_usd
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'completed'
    GROUP BY o.order_date
) daily
ORDER BY order_date;

-- 3.4 Rank customers by lifetime spend (window function: RANK)
-- Identifies top customers — candidates for the deck's planned
-- "micro-influencer partnerships" (Phase 4: Scale)
SELECT
    customer_id,
    total_spend_usd,
    RANK() OVER (ORDER BY total_spend_usd DESC) AS spend_rank
FROM (
    SELECT
        o.customer_id,
        SUM(oi.quantity * oi.unit_price_usd) AS total_spend_usd
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'completed'
    GROUP BY o.customer_id
) customer_totals
ORDER BY spend_rank
LIMIT 20;
