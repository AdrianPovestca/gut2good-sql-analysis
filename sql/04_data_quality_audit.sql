-- =========================================================
-- 04_data_quality_audit.sql
-- This file mirrors the real audit work described in the CV:
-- flagging anomalies, duplicates, and discrepancies in
-- transactional e-commerce data before they affect reporting.
-- =========================================================

-- 4.1 Orders flagged as duplicate or refunded — what % of total volume?
-- (the kind of audit summary a stakeholder would want first)
SELECT
    order_status,
    COUNT(*) AS order_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM orders), 2) AS pct_of_total_orders
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

-- 4.2 Customers with more than one order on the exact same day
-- (classic duplicate-order pattern flagged via subquery + HAVING)
SELECT
    customer_id,
    order_date,
    COUNT(*) AS orders_same_day
FROM orders
WHERE order_status != 'duplicate'   -- check beyond just the labeled ones
GROUP BY customer_id, order_date
HAVING COUNT(*) > 1
ORDER BY orders_same_day DESC;

-- 4.3 Revenue lost to refunds and duplicates, by month
-- (turns a data-quality issue into a dollar figure stakeholders act on)
SELECT
    strftime('%Y-%m', o.order_date) AS month,
    o.order_status,
    SUM(oi.quantity * oi.unit_price_usd) AS affected_revenue_usd
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status IN ('refunded', 'duplicate')
GROUP BY month, o.order_status
ORDER BY month, o.order_status;

-- 4.4 Orders with no matching order_items (referential/orphan check)
-- A real-world data integrity check: did every order actually
-- get a line item recorded, or did something drop during ETL?
SELECT o.order_id, o.order_date, o.customer_id
FROM orders o
LEFT JOIN order_items oi ON oi.order_id = o.order_id
WHERE oi.order_item_id IS NULL;
