-- =========================================================
-- Gut2Good — US Market Expansion Analysis
-- Schema: e-commerce sales, marketing traffic, and product data
-- Dialect: PostgreSQL (works with minor tweaks in MySQL/SQLite)
-- =========================================================

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS marketing_traffic;

-- Products sold by Gut2God (digital gut-health products)
CREATE TABLE products (
    product_id      INTEGER PRIMARY KEY,
    product_name    VARCHAR(100) NOT NULL,
    category        VARCHAR(50) NOT NULL,         -- 'Reset Guide', 'Recipe Guide', 'Upsell'
    price_usd        NUMERIC(10,2) NOT NULL,
    launch_date     DATE NOT NULL
);

-- Customers (US market expansion target)
CREATE TABLE customers (
    customer_id     INTEGER PRIMARY KEY,
    signup_date     DATE NOT NULL,
    country         VARCHAR(50) NOT NULL,
    acquisition_channel VARCHAR(50) NOT NULL,      -- 'Pinterest', 'Facebook', 'Organic', 'Referral'
    age_bracket     VARCHAR(20)                    -- 'Millennial', 'Gen Z', 'Gen X'
);

-- Orders placed
CREATE TABLE orders (
    order_id        INTEGER PRIMARY KEY,
    customer_id     INTEGER NOT NULL REFERENCES customers(customer_id),
    order_date      DATE NOT NULL,
    channel         VARCHAR(50) NOT NULL,           -- traffic source at time of purchase
    order_status    VARCHAR(20) NOT NULL DEFAULT 'completed'  -- 'completed', 'refunded', 'duplicate'
);

-- Order line items (one order can contain multiple products / upsells)
CREATE TABLE order_items (
    order_item_id   INTEGER PRIMARY KEY,
    order_id        INTEGER NOT NULL REFERENCES orders(order_id),
    product_id      INTEGER NOT NULL REFERENCES products(product_id),
    quantity        INTEGER NOT NULL DEFAULT 1,
    unit_price_usd  NUMERIC(10,2) NOT NULL
);

-- Daily marketing traffic by channel (site visits vs conversions)
CREATE TABLE marketing_traffic (
    traffic_id      INTEGER PRIMARY KEY,
    traffic_date    DATE NOT NULL,
    channel         VARCHAR(50) NOT NULL,           -- 'Pinterest', 'Facebook'
    visits          INTEGER NOT NULL,
    conversions     INTEGER NOT NULL
);
