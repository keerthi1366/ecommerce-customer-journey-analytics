"""
Power BI Star Schema Dimensional Modeler & Exporter
Author: BI Engineering Team
Description: Transforms raw relational e-commerce datasets into clean, Kimball-standard
             Star Schema dimension and fact tables for Power BI.
"""

import os
import pandas as pd
import numpy as np

DATA_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "data"))
PBI_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "powerbi", "star_schema_tables"))
os.makedirs(PBI_DIR, exist_ok=True)

def generate_dim_date():
    """Generates a complete Date Dimension table for Power BI time intelligence."""
    dates = pd.date_range(start="2025-01-01", end="2025-12-31", freq="D")
    dim_date = pd.DataFrame({"full_date": dates})
    dim_date["date_key"] = dim_date["full_date"].dt.strftime("%Y%m%d").astype(int)
    dim_date["year"] = dim_date["full_date"].dt.year
    dim_date["quarter"] = dim_date["full_date"].dt.quarter
    dim_date["quarter_name"] = "Q" + dim_date["quarter"].astype(str)
    dim_date["month"] = dim_date["full_date"].dt.month
    dim_date["month_name"] = dim_date["full_date"].dt.strftime("%B")
    dim_date["month_year"] = dim_date["full_date"].dt.strftime("%b %Y")
    dim_date["day_of_month"] = dim_date["full_date"].dt.day
    dim_date["day_name"] = dim_date["full_date"].dt.strftime("%A")
    dim_date["is_weekend"] = dim_date["full_date"].dt.dayofweek.isin([5, 6]).astype(int)
    dim_date["fiscal_quarter"] = "FQ" + dim_date["quarter"].astype(str)
    return dim_date

def build_star_schema():
    print("==================================================")
    print("Building Kimball Star Schema for Power BI")
    print("==================================================")

    # 1. Dimension: Date
    dim_date = generate_dim_date()
    dim_date.to_csv(os.path.join(PBI_DIR, "dim_date.csv"), index=False)
    print(f"[OK] dim_date: {len(dim_date)} rows")

    # 2. Dimension: Device
    dim_device = pd.DataFrame([
        {"device_key": 1, "device_type": "Desktop", "form_factor": "Computer", "touch_enabled": 0},
        {"device_key": 2, "device_type": "Mobile", "form_factor": "Handheld Smartphone", "touch_enabled": 1},
        {"device_key": 3, "device_type": "Tablet", "form_factor": "Touch Tablet", "touch_enabled": 1}
    ])
    dim_device.to_csv(os.path.join(PBI_DIR, "dim_device.csv"), index=False)
    print(f"[OK] dim_device: {len(dim_device)} rows")

    # 3. Dimension: Channel
    dim_channel = pd.DataFrame([
        {"channel_key": 1, "traffic_source": "Organic Search", "channel_group": "Organic", "cost_structure": "Zero Direct Cost"},
        {"channel_key": 2, "traffic_source": "Direct", "channel_group": "Direct", "cost_structure": "Zero Direct Cost"},
        {"channel_key": 3, "traffic_source": "Paid Search", "channel_group": "Paid Marketing", "cost_structure": "PPC Cost"},
        {"channel_key": 4, "traffic_source": "Paid Social", "channel_group": "Paid Marketing", "cost_structure": "Impression/CPC Cost"},
        {"channel_key": 5, "traffic_source": "Email", "channel_group": "Owned Media", "cost_structure": "Campaign Cost"},
        {"channel_key": 6, "traffic_source": "Affiliate", "channel_group": "Partner", "cost_structure": "Commission Cost"}
    ])
    dim_channel.to_csv(os.path.join(PBI_DIR, "dim_channel.csv"), index=False)
    print(f"[OK] dim_channel: {len(dim_channel)} rows")

    # 4. Dimension: Payment Method
    dim_payment = pd.DataFrame([
        {"payment_method_key": 1, "payment_method": "Credit Card", "payment_category": "Credit", "processing_fee_pct": 2.9},
        {"payment_method_key": 2, "payment_method": "Debit Card", "payment_category": "Debit", "processing_fee_pct": 1.5},
        {"payment_method_key": 3, "payment_method": "PayPal", "payment_category": "Digital Wallet", "processing_fee_pct": 3.4},
        {"payment_method_key": 4, "payment_method": "Apple Pay", "payment_category": "Mobile Wallet", "processing_fee_pct": 2.2},
        {"payment_method_key": 5, "payment_method": "Buy Now Pay Later", "payment_category": "Financing / Installment", "processing_fee_pct": 5.0}
    ])
    dim_payment.to_csv(os.path.join(PBI_DIR, "dim_payment_method.csv"), index=False)
    print(f"[OK] dim_payment_method: {len(dim_payment)} rows")

    # 5. Dimension: Product
    df_products = pd.read_csv(os.path.join(DATA_DIR, "products.csv"))
    df_products["product_key"] = df_products["product_id"]
    df_products["profit_margin_pct"] = round((df_products["retail_price"] - df_products["cost_price"]) * 100.0 / df_products["retail_price"], 2)
    df_products["price_tier"] = pd.cut(
        df_products["retail_price"],
        bins=[0, 35, 75, 150, 10000],
        labels=["Budget (< $35)", "Mid-Tier ($35-$75)", "Premium ($75-$150)", "Luxury / Flagship ($150+)"]
    )
    df_products.to_csv(os.path.join(PBI_DIR, "dim_product.csv"), index=False)
    print(f"[OK] dim_product: {len(df_products)} rows")

    # 6. Dimension: User
    df_users = pd.read_csv(os.path.join(DATA_DIR, "users.csv"))
    df_users["user_key"] = df_users["user_id"]
    df_users["full_name"] = df_users["first_name"] + " " + df_users["last_name"]
    df_users["cohort_month"] = pd.to_datetime(df_users["signup_date"]).dt.strftime("%Y-%m")
    df_users.to_csv(os.path.join(PBI_DIR, "dim_user.csv"), index=False)
    print(f"[OK] dim_user: {len(df_users)} rows")

    # Mapping helpers for foreign keys
    device_map = dict(zip(dim_device["device_type"], dim_device["device_key"]))
    channel_map = dict(zip(dim_channel["traffic_source"], dim_channel["channel_key"]))
    payment_map = dict(zip(dim_payment["payment_method"], dim_payment["payment_method_key"]))

    # 7. Fact: Sessions
    df_sessions = pd.read_csv(os.path.join(DATA_DIR, "web_sessions.csv"))
    df_sessions["date_key"] = pd.to_datetime(df_sessions["session_start"]).dt.strftime("%Y%m%d").astype(int)
    df_sessions["user_key"] = df_sessions["user_id"].fillna(0).astype(int)
    df_sessions["device_key"] = df_sessions["device_type"].map(device_map).fillna(1).astype(int)
    df_sessions["channel_key"] = df_sessions["traffic_source"].map(channel_map).fillna(1).astype(int)
    
    fact_sessions = df_sessions[[
        "session_id", "user_key", "date_key", "device_key", "channel_key",
        "page_views", "duration_seconds", "is_bounced", "has_converted"
    ]]
    fact_sessions.to_csv(os.path.join(PBI_DIR, "fact_sessions.csv"), index=False)
    print(f"[OK] fact_sessions: {len(fact_sessions)} rows")

    # 8. Fact: Events
    df_events = pd.read_csv(os.path.join(DATA_DIR, "funnel_events.csv"))
    df_events["date_key"] = pd.to_datetime(df_events["event_timestamp"]).dt.strftime("%Y%m%d").astype(int)
    df_events["user_key"] = df_events["user_id"].fillna(0).astype(int)
    df_events["product_key"] = df_events["product_id"].fillna(0).astype(int)
    
    fact_events = df_events[[
        "event_id", "session_id", "user_key", "product_key", "date_key",
        "event_name", "page_type", "page_load_ms", "event_timestamp"
    ]]
    fact_events.to_csv(os.path.join(PBI_DIR, "fact_events.csv"), index=False)
    print(f"[OK] fact_events: {len(fact_events)} rows")

    # 9. Fact: Orders
    df_orders = pd.read_csv(os.path.join(DATA_DIR, "orders.csv"))
    df_orders["date_key"] = pd.to_datetime(df_orders["order_timestamp"]).dt.strftime("%Y%m%d").astype(int)
    df_orders["user_key"] = df_orders["user_id"].astype(int)
    
    fact_orders = df_orders[[
        "order_id", "user_key", "session_id", "date_key", "subtotal",
        "discount_amount", "shipping_fee", "tax_amount", "total_amount",
        "order_status", "shipping_method"
    ]]
    fact_orders.to_csv(os.path.join(PBI_DIR, "fact_orders.csv"), index=False)
    print(f"[OK] fact_orders: {len(fact_orders)} rows")

    # 10. Fact: Order Items
    df_items = pd.read_csv(os.path.join(DATA_DIR, "order_items.csv"))
    df_items["product_key"] = df_items["product_id"].astype(int)
    # Merge cost from products to compute line cost and profit
    prod_cost_map = dict(zip(df_products["product_id"], df_products["cost_price"]))
    df_items["unit_cost"] = df_items["product_id"].map(prod_cost_map)
    df_items["line_cost"] = round(df_items["unit_cost"] * df_items["quantity"], 2)
    df_items["line_profit"] = round(df_items["line_total"] - df_items["line_cost"], 2)
    
    df_items.to_csv(os.path.join(PBI_DIR, "fact_order_items.csv"), index=False)
    print(f"[OK] fact_order_items: {len(df_items)} rows")

    # 11. Fact: Payments
    df_payments = pd.read_csv(os.path.join(DATA_DIR, "payments.csv"))
    df_payments["date_key"] = pd.to_datetime(df_payments["payment_timestamp"]).dt.strftime("%Y%m%d").astype(int)
    df_payments["payment_method_key"] = df_payments["payment_method"].map(payment_map).fillna(1).astype(int)
    
    df_payments.to_csv(os.path.join(PBI_DIR, "fact_payments.csv"), index=False)
    print(f"[OK] fact_payments: {len(df_payments)} rows")

    print("\nAll 11 Power BI Star Schema tables successfully exported!")

if __name__ == "__main__":
    build_star_schema()
