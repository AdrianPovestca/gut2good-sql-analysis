import random
from datetime import date, timedelta

random.seed(42)

OUT_DIR = "/home/claude/gut2good-sql-analysis/data"

# ---------------------------------------------------------
# 1. PRODUCTS — based on the deck's "Core Digital Offerings"
#    Revenue split target: 60% / 30% / 10% (Reset / Recipe / Upsell)
# ---------------------------------------------------------
products = [
    (1, "7-Day Anti-Bloat Reset", "Reset Guide", 27.00, "2026-01-15"),
    (2, "15-Minute Recipe Guide", "Recipe Guide", 19.00, "2026-02-01"),
    (3, "Custom Gut Health Plan", "Upsell", 47.00, "2026-03-10"),
]

# ---------------------------------------------------------
# 2. CUSTOMERS
#    Acquisition channel mix reflects the deck's traffic strategy:
#    Pinterest (search intent, 2.2% conv) vs Facebook (interruption, 1.2% conv)
# ---------------------------------------------------------
N_CUSTOMERS = 1400
channels = ["Pinterest", "Facebook", "Organic", "Referral"]
channel_weights = [0.45, 0.30, 0.18, 0.07]  # Pinterest weighted heavier per deck's strategy
age_brackets = ["Millennial", "Gen Z", "Gen X"]
age_weights = [0.55, 0.30, 0.15]

start_date = date(2026, 1, 15)
end_date = date(2026, 6, 24)
total_days = (end_date - start_date).days

customers = []
for cid in range(1, N_CUSTOMERS + 1):
    signup_offset = random.randint(0, total_days)
    signup_date = start_date + timedelta(days=signup_offset)
    channel = random.choices(channels, weights=channel_weights)[0]
    age = random.choices(age_brackets, weights=age_weights)[0]
    customers.append((cid, signup_date.isoformat(), "USA", channel, age))

# ---------------------------------------------------------
# 3. MARKETING TRAFFIC — daily visits/conversions per channel
#    Calibrated to match deck: Pinterest 2.2% conversion, Facebook 1.2%
# ---------------------------------------------------------
traffic_rows = []
traffic_id = 1
for d in range(total_days + 1):
    current_date = start_date + timedelta(days=d)
    # Pinterest: higher intent traffic, lower volume, higher conversion
    pin_visits = random.randint(80, 220)
    pin_conversions = round(pin_visits * random.uniform(0.018, 0.026))
    traffic_rows.append((traffic_id, current_date.isoformat(), "Pinterest", pin_visits, pin_conversions))
    traffic_id += 1

    # Facebook: higher volume (interruption-based), lower conversion
    fb_visits = random.randint(150, 380)
    fb_conversions = round(fb_visits * random.uniform(0.008, 0.016))
    traffic_rows.append((traffic_id, current_date.isoformat(), "Facebook", fb_visits, fb_conversions))
    traffic_id += 1

# ---------------------------------------------------------
# 4. ORDERS + ORDER ITEMS
#    Revenue split target ~60% Reset / 30% Recipe / 10% Upsell
#    A small % of orders are flagged 'refunded' or 'duplicate' (audit realism)
# ---------------------------------------------------------
orders = []
order_items = []
order_id = 1
order_item_id = 1

product_weights_by_category = {
    1: 0.55,   # Reset Guide — primary product
    2: 0.30,   # Recipe Guide
    3: 0.15,   # Upsell — often added on top, slightly higher than pure 10% since it's add-on heavy
}

for cust in customers:
    cid, signup_date_str, country, channel, age = cust
    signup_date = date.fromisoformat(signup_date_str)

    # Not every customer buys — ~70% convert to at least one order (portfolio-realistic, not literal ad conversion rate)
    if random.random() > 0.70:
        continue

    n_orders = random.choices([1, 2, 3], weights=[0.75, 0.20, 0.05])[0]
    last_order_date = signup_date

    for _ in range(n_orders):
        order_offset = random.randint(0, 5)
        order_date = last_order_date + timedelta(days=order_offset)
        if order_date > end_date:
            break
        last_order_date = order_date + timedelta(days=random.randint(1, 20))

        status = random.choices(
            ["completed", "refunded", "duplicate"],
            weights=[0.90, 0.07, 0.03]
        )[0]

        orders.append((order_id, cid, order_date.isoformat(), channel, status))

        # Each order has 1-2 line items
        n_items = random.choices([1, 2], weights=[0.8, 0.2])[0]
        chosen_products = random.choices(
            list(product_weights_by_category.keys()),
            weights=list(product_weights_by_category.values()),
            k=n_items
        )
        for pid in set(chosen_products):
            price = next(p[3] for p in products if p[0] == pid)
            qty = 1
            order_items.append((order_item_id, order_id, pid, qty, price))
            order_item_id += 1

        order_id += 1

# ---------------------------------------------------------
# WRITE CSVs
# ---------------------------------------------------------
import csv

def write_csv(filename, header, rows):
    with open(f"{OUT_DIR}/{filename}", "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(header)
        writer.writerows(rows)

write_csv("products.csv", ["product_id", "product_name", "category", "price_usd", "launch_date"], products)
write_csv("customers.csv", ["customer_id", "signup_date", "country", "acquisition_channel", "age_bracket"], customers)
write_csv("marketing_traffic.csv", ["traffic_id", "traffic_date", "channel", "visits", "conversions"], traffic_rows)
write_csv("orders.csv", ["order_id", "customer_id", "order_date", "channel", "order_status"], orders)
write_csv("order_items.csv", ["order_item_id", "order_id", "product_id", "quantity", "unit_price_usd"], order_items)

print(f"Customers: {len(customers)}")
print(f"Orders: {len(orders)}")
print(f"Order items: {len(order_items)}")
print(f"Traffic rows: {len(traffic_rows)}")
