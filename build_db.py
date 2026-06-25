import sqlite3
import csv

DB_PATH = "/home/claude/gut2good-sql-analysis/data/gut2good.db"
DATA_DIR = "/home/claude/gut2good-sql-analysis/data"

conn = sqlite3.connect(DB_PATH)
cur = conn.cursor()

cur.executescript("""
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS marketing_traffic;

CREATE TABLE products (
    product_id      INTEGER PRIMARY KEY,
    product_name    TEXT NOT NULL,
    category        TEXT NOT NULL,
    price_usd       REAL NOT NULL,
    launch_date     TEXT NOT NULL
);

CREATE TABLE customers (
    customer_id     INTEGER PRIMARY KEY,
    signup_date     TEXT NOT NULL,
    country         TEXT NOT NULL,
    acquisition_channel TEXT NOT NULL,
    age_bracket     TEXT
);

CREATE TABLE orders (
    order_id        INTEGER PRIMARY KEY,
    customer_id     INTEGER NOT NULL REFERENCES customers(customer_id),
    order_date      TEXT NOT NULL,
    channel         TEXT NOT NULL,
    order_status    TEXT NOT NULL DEFAULT 'completed'
);

CREATE TABLE order_items (
    order_item_id   INTEGER PRIMARY KEY,
    order_id        INTEGER NOT NULL REFERENCES orders(order_id),
    product_id      INTEGER NOT NULL REFERENCES products(product_id),
    quantity        INTEGER NOT NULL DEFAULT 1,
    unit_price_usd  REAL NOT NULL
);

CREATE TABLE marketing_traffic (
    traffic_id      INTEGER PRIMARY KEY,
    traffic_date    TEXT NOT NULL,
    channel         TEXT NOT NULL,
    visits          INTEGER NOT NULL,
    conversions     INTEGER NOT NULL
);
""")

def load_csv(table, filename):
    with open(f"{DATA_DIR}/{filename}") as f:
        reader = csv.reader(f)
        header = next(reader)
        rows = list(reader)
        placeholders = ",".join(["?"] * len(header))
        cur.executemany(f"INSERT INTO {table} VALUES ({placeholders})", rows)

load_csv("products", "products.csv")
load_csv("customers", "customers.csv")
load_csv("orders", "orders.csv")
load_csv("order_items", "order_items.csv")
load_csv("marketing_traffic", "marketing_traffic.csv")

conn.commit()

# Quick sanity check
for t in ["products", "customers", "orders", "order_items", "marketing_traffic"]:
    cur.execute(f"SELECT COUNT(*) FROM {t}")
    print(t, cur.fetchone()[0])

conn.close()
print("DB built successfully at", DB_PATH)
