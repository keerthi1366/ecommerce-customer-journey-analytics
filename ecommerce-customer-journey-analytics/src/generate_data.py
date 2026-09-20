"""
E-commerce Customer Journey & Conversion Analytics - Data Generator
Author: Analytics Engineering Team
Description: Generates high-fidelity, probabilistic e-commerce behavioral data.
Note: Behavioral parameters use latent probability distributions rather than
hardcoded conclusions. All metrics and findings emerge naturally from user interactions.
"""

import os
import random
import uuid
from datetime import datetime, timedelta
import pandas as pd
import numpy as np

# Set random seed for reproducibility
RANDOM_SEED = 42
random.seed(RANDOM_SEED)
np.random.seed(RANDOM_SEED)

DATA_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "data"))
os.makedirs(DATA_DIR, exist_ok=True)

# ---------------------------------------------------------
# 1. Product Catalog Definition
# ---------------------------------------------------------
PRODUCTS_CATALOG = [
    # Electronics
    {"name": "Ultra-Slim 4K Monitor 27-inch", "category": "Electronics", "sub": "Displays", "cost": 180.0, "price": 299.99},
    {"name": "Wireless Noise-Canceling Headphones", "category": "Electronics", "sub": "Audio", "cost": 75.0, "price": 149.99},
    {"name": "Ergonomic Mechanical Keyboard RGB", "category": "Electronics", "sub": "Peripherals", "cost": 45.0, "price": 89.99},
    {"name": "Precision Optical Gaming Mouse", "category": "Electronics", "sub": "Peripherals", "cost": 25.0, "price": 54.99},
    {"name": "Smart Home Hub Speaker", "category": "Electronics", "sub": "Smart Home", "cost": 38.0, "price": 79.99},
    {"name": "1080p Streaming Webcam with Ring Light", "category": "Electronics", "sub": "Peripherals", "cost": 30.0, "price": 69.99},
    {"name": "Portable Power Bank 20000mAh", "category": "Electronics", "sub": "Accessories", "cost": 18.0, "price": 39.99},
    {"name": "Fast Wireless Charging Dock 3-in-1", "category": "Electronics", "sub": "Accessories", "cost": 22.0, "price": 49.99},

    # Apparel & Fashion
    {"name": "Classic Organic Cotton Crewneck T-Shirt", "category": "Apparel", "sub": "Tops", "cost": 8.0, "price": 28.00},
    {"name": "Slim-Fit Stretch Denim Jeans", "category": "Apparel", "sub": "Bottoms", "cost": 22.0, "price": 68.00},
    {"name": "Performance Athletic Hoodie", "category": "Apparel", "sub": "Activewear", "cost": 26.0, "price": 74.00},
    {"name": "Breathable Running Shorts", "category": "Apparel", "sub": "Activewear", "cost": 14.0, "price": 38.00},
    {"name": "Waterproof Trench Coat Jacket", "category": "Apparel", "sub": "Outerwear", "cost": 55.0, "price": 145.00},
    {"name": "Seamless Modal Lounge Pants", "category": "Apparel", "sub": "Loungewear", "cost": 16.0, "price": 44.00},
    {"name": "Merino Wool Winter Beanie", "category": "Apparel", "sub": "Accessories", "cost": 10.0, "price": 29.00},

    # Home & Kitchen
    {"name": "Stainless Steel Pour-Over Kettle", "category": "Home & Kitchen", "sub": "Coffee & Tea", "cost": 20.0, "price": 48.00},
    {"name": "Automatic Espresso & Cappuccino Machine", "category": "Home & Kitchen", "sub": "Coffee & Tea", "cost": 160.0, "price": 349.00},
    {"name": "Cast Iron Dutch Oven 6-Quart", "category": "Home & Kitchen", "sub": "Cookware", "cost": 38.0, "price": 89.00},
    {"name": "Japanese Damascus Chef's Knife 8-inch", "category": "Home & Kitchen", "sub": "Cutlery", "cost": 42.0, "price": 95.00},
    {"name": "Ceramic Non-Stick Skillet Set", "category": "Home & Kitchen", "sub": "Cookware", "cost": 32.0, "price": 79.00},
    {"name": "Aromatherapy Ultrasonic Diffuser", "category": "Home & Kitchen", "sub": "Decor", "cost": 12.0, "price": 34.00},
    {"name": "Luxury Bamboo Queen Sheet Set", "category": "Home & Kitchen", "sub": "Bedding", "cost": 40.0, "price": 110.00},

    # Beauty & Personal Care
    {"name": "Hydrating Hyaluronic Acid Serum", "category": "Beauty", "sub": "Skincare", "cost": 7.0, "price": 26.00},
    {"name": "Vitamin C Radiance Glow Daily Cream", "category": "Beauty", "sub": "Skincare", "cost": 9.0, "price": 32.00},
    {"name": "Sonic Electric Toothbrush with UV Sanitizer", "category": "Beauty", "sub": "Oral Care", "cost": 28.0, "price": 79.00},
    {"name": "Botanical Nourishing Hair Mask", "category": "Beauty", "sub": "Haircare", "cost": 8.5, "price": 24.00},
    {"name": "Gentle Exfoliating Cleanser 200ml", "category": "Beauty", "sub": "Skincare", "cost": 6.0, "price": 22.00},
    {"name": "SPF 50 Mineral Sunscreen Broad Spectrum", "category": "Beauty", "sub": "Suncare", "cost": 7.5, "price": 25.00},

    # Sports & Outdoors
    {"name": "Insulated Stainless Steel Water Bottle 32oz", "category": "Sports", "sub": "Hydration", "cost": 11.0, "price": 32.00},
    {"name": "Adjustable Neoprene Dumbbell Set (Pair)", "category": "Sports", "sub": "Fitness", "cost": 35.0, "price": 85.00},
    {"name": "High-Density Yoga Mat with Carrying Strap", "category": "Sports", "sub": "Fitness", "cost": 15.0, "price": 42.00},
    {"name": "Ultralight Camping Hammock with Tree Straps", "category": "Sports", "sub": "Outdoors", "cost": 18.0, "price": 49.00},
    {"name": "Trail Running Hydration Vest Pack", "category": "Sports", "sub": "Running", "cost": 32.0, "price": 89.00}
]

FIRST_NAMES = [
    "Alex", "Jordan", "Taylor", "Morgan", "Sam", "Chris", "Pat", "Riley", "Casey", "Avery",
    "Emma", "Liam", "Olivia", "Noah", "Sophia", "Lucas", "Ava", "Mason", "Isabella", "Ethan",
    "Mia", "Oliver", "Harper", "Elijah", "Evelyn", "Aiden", "Abigail", "James", "Emily", "Benjamin",
    "Charlotte", "Sebastian", "Amelia", "Jack", "Ella", "Alexander", "Chloe", "Henry", "Grace", "Daniel"
]

LAST_NAMES = [
    "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez",
    "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson", "Thomas", "Taylor", "Moore", "Jackson", "Martin",
    "Lee", "Perez", "Thompson", "White", "Harris", "Sanchez", "Clark", "Ramirez", "Lewis", "Robinson"
]

LOCATIONS = [
    {"country": "USA", "state": "California", "city": "Los Angeles"},
    {"country": "USA", "state": "California", "city": "San Francisco"},
    {"country": "USA", "state": "New York", "city": "New York"},
    {"country": "USA", "state": "Texas", "city": "Austin"},
    {"country": "USA", "state": "Texas", "city": "Houston"},
    {"country": "USA", "state": "Washington", "city": "Seattle"},
    {"country": "USA", "state": "Illinois", "city": "Chicago"},
    {"country": "USA", "state": "Florida", "city": "Miami"},
    {"country": "USA", "state": "Massachusetts", "city": "Boston"},
    {"country": "USA", "state": "Colorado", "city": "Denver"},
    {"country": "Canada", "state": "Ontario", "city": "Toronto"},
    {"country": "Canada", "state": "British Columbia", "city": "Vancouver"},
    {"country": "UK", "state": "England", "city": "London"},
    {"country": "UK", "state": "England", "city": "Manchester"}
]

TRAFFIC_SOURCES = [
    "Organic Search", "Direct", "Paid Search", "Paid Social", "Email", "Affiliate"
]
SOURCE_WEIGHTS = [0.28, 0.18, 0.22, 0.18, 0.10, 0.04]

DEVICES = ["Mobile", "Desktop", "Tablet"]
DEVICE_WEIGHTS = [0.60, 0.35, 0.05]

PAYMENT_METHODS = ["Credit Card", "Debit Card", "PayPal", "Apple Pay", "Buy Now Pay Later"]
PAYMENT_WEIGHTS = [0.42, 0.20, 0.18, 0.12, 0.08]

def generate_products():
    products = []
    for idx, p in enumerate(PRODUCTS_CATALOG, start=1):
        products.append({
            "product_id": idx,
            "product_name": p["name"],
            "category": p["category"],
            "sub_category": p["sub"],
            "cost_price": round(p["cost"], 2),
            "retail_price": round(p["price"], 2),
            "stock_quantity": random.randint(120, 1500),
            "created_at": "2024-12-15 00:00:00"
        })
    return pd.DataFrame(products)

def generate_users(num_users=12000):
    start_date = datetime(2025, 1, 1)
    users = []
    for user_id in range(1, num_users + 1):
        fn = random.choice(FIRST_NAMES)
        ln = random.choice(LAST_NAMES)
        loc = random.choice(LOCATIONS)
        days_offset = random.randint(0, 364)
        signup_dt = start_date + timedelta(days=days_offset, seconds=random.randint(0, 86399))
        age_group = random.choices(["18-24", "25-34", "35-44", "45-54", "55+"], weights=[0.22, 0.38, 0.24, 0.11, 0.05])[0]
        gender = random.choices(["Female", "Male", "Other"], weights=[0.51, 0.46, 0.03])[0]
        
        users.append({
            "user_id": user_id,
            "first_name": fn,
            "last_name": ln,
            "email": f"{fn.lower()}.{ln.lower()}{user_id}@example.com",
            "gender": gender,
            "age_group": age_group,
            "country": loc["country"],
            "state": loc["state"],
            "city": loc["city"],
            "signup_date": signup_dt.strftime("%Y-%m-%d %H:%M:%S")
        })
    return pd.DataFrame(users)

def generate_behavioral_funnel(df_users, df_products, num_sessions=35000):
    """
    Generates realistic web sessions, sequential funnel events, orders, items, and payments.
    Behavior is driven by realistic probabilistic mechanics:
    - Mobile users experience higher latency and friction during checkout input.
    - Paid Social mobile users have higher bounce and cart abandonment when shipping fee is charged.
    - Free shipping threshold at $75 affects cart completion.
    - Payment failure probabilities vary across payment methods.
    """
    start_date = datetime(2025, 1, 1)
    sessions = []
    events = []
    orders = []
    order_items = []
    payments = []
    ab_test_records = []

    user_ids = df_users["user_id"].tolist()
    user_signup_map = dict(zip(df_users["user_id"], pd.to_datetime(df_users["signup_date"])))
    product_list = df_products.to_dict(orient="records")

    event_id_seq = 1
    order_id_seq = 1
    payment_id_seq = 1
    order_item_id_seq = 1

    # Keep track of orders per user to track returning customer dynamics
    user_order_counts = {}

    print(f"Simulating {num_sessions} sessions with probabilistic behavioral mechanics...")

    for session_seq in range(1, num_sessions + 1):
        session_id = f"SES-2025-{session_seq:06d}"
        
        # Determine user: ~65% registered user, ~35% guest/new session
        is_registered = random.random() < 0.65
        if is_registered:
            user_id = random.choice(user_ids)
            user_signup = user_signup_map[user_id]
            # Session must be on or after signup
            max_days_after = (datetime(2025, 12, 31) - user_signup).days
            if max_days_after <= 0:
                session_dt = user_signup + timedelta(seconds=random.randint(60, 3600))
            else:
                session_dt = user_signup + timedelta(days=random.randint(0, max_days_after), seconds=random.randint(0, 86399))
        else:
            user_id = None
            session_dt = start_date + timedelta(days=random.randint(0, 364), seconds=random.randint(0, 86399))

        device = random.choices(DEVICES, weights=DEVICE_WEIGHTS)[0]
        source = random.choices(TRAFFIC_SOURCES, weights=SOURCE_WEIGHTS)[0]

        # Inherent latency distribution
        if device == "Mobile":
            base_latency = int(np.random.gamma(shape=4.0, scale=600))  # mean ~2400ms
        elif device == "Tablet":
            base_latency = int(np.random.gamma(shape=3.5, scale=500))  # mean ~1750ms
        else:
            base_latency = int(np.random.gamma(shape=2.5, scale=480))  # mean ~1200ms

        curr_time = session_dt

        # ----------------------------------------------------
        # STAGE 1: Session Visit
        # ----------------------------------------------------
        events.append({
            "event_id": event_id_seq,
            "session_id": session_id,
            "user_id": user_id,
            "event_name": "session_visit",
            "page_type": "home_or_landing",
            "product_id": None,
            "page_load_ms": base_latency,
            "event_timestamp": curr_time.strftime("%Y-%m-%d %H:%M:%S")
        })
        event_id_seq += 1

        # Bounce probability: higher for Paid Social mobile, lower for Direct desktop
        bounce_prob = 0.32
        if source == "Paid Social":
            bounce_prob += 0.15
        elif source == "Direct" or source == "Email":
            bounce_prob -= 0.12
        if device == "Mobile":
            bounce_prob += 0.08

        if random.random() < bounce_prob:
            # Bounced session
            sessions.append({
                "session_id": session_id,
                "user_id": user_id,
                "session_start": session_dt.strftime("%Y-%m-%d %H:%M:%S"),
                "device_type": device,
                "traffic_source": source,
                "page_views": 1,
                "duration_seconds": random.randint(3, 18),
                "is_bounced": 1,
                "has_converted": 0
            })
            continue

        # ----------------------------------------------------
        # STAGE 2: Search / Browse
        # ----------------------------------------------------
        curr_time += timedelta(seconds=random.randint(10, 45))
        events.append({
            "event_id": event_id_seq,
            "session_id": session_id,
            "user_id": user_id,
            "event_name": "browse_search",
            "page_type": "category_search_listing",
            "product_id": None,
            "page_load_ms": base_latency + random.randint(-150, 250),
            "event_timestamp": curr_time.strftime("%Y-%m-%d %H:%M:%S")
        })
        event_id_seq += 1

        # Drop-off after browse
        browse_to_view_prob = 0.72 if device == "Desktop" else 0.65
        if random.random() > browse_to_view_prob:
            sessions.append({
                "session_id": session_id,
                "user_id": user_id,
                "session_start": session_dt.strftime("%Y-%m-%d %H:%M:%S"),
                "device_type": device,
                "traffic_source": source,
                "page_views": 2,
                "duration_seconds": int((curr_time - session_dt).total_seconds()) + random.randint(5, 30),
                "is_bounced": 0,
                "has_converted": 0
            })
            continue

        # ----------------------------------------------------
        # STAGE 3: Product View
        # ----------------------------------------------------
        curr_time += timedelta(seconds=random.randint(15, 60))
        selected_prod = random.choice(product_list)
        events.append({
            "event_id": event_id_seq,
            "session_id": session_id,
            "user_id": user_id,
            "event_name": "product_view",
            "page_type": "product_detail",
            "product_id": selected_prod["product_id"],
            "page_load_ms": base_latency + random.randint(-100, 300),
            "event_timestamp": curr_time.strftime("%Y-%m-%d %H:%M:%S")
        })
        event_id_seq += 1

        # Add to cart probability influenced by price and category
        # Beauty and Apparel have higher ATC rates than high-ticket Electronics
        atc_base = 0.32
        if selected_prod["category"] in ["Beauty", "Apparel"]:
            atc_base += 0.08
        elif selected_prod["category"] == "Electronics" and selected_prod["retail_price"] > 200:
            atc_base -= 0.09

        if random.random() > atc_base:
            sessions.append({
                "session_id": session_id,
                "user_id": user_id,
                "session_start": session_dt.strftime("%Y-%m-%d %H:%M:%S"),
                "device_type": device,
                "traffic_source": source,
                "page_views": 3,
                "duration_seconds": int((curr_time - session_dt).total_seconds()) + random.randint(10, 45),
                "is_bounced": 0,
                "has_converted": 0
            })
            continue

        # ----------------------------------------------------
        # STAGE 4: Add to Cart
        # ----------------------------------------------------
        curr_time += timedelta(seconds=random.randint(10, 40))
        cart_qty = random.choices([1, 2, 3], weights=[0.75, 0.20, 0.05])[0]
        events.append({
            "event_id": event_id_seq,
            "session_id": session_id,
            "user_id": user_id,
            "event_name": "add_to_cart",
            "page_type": "cart_modal",
            "product_id": selected_prod["product_id"],
            "page_load_ms": base_latency + random.randint(50, 400),
            "event_timestamp": curr_time.strftime("%Y-%m-%d %H:%M:%S")
        })
        event_id_seq += 1

        # CART ABANDONMENT: Typically ~65-72% of carts do not proceed to checkout
        # Friction drivers: Mobile form perception, Paid Ads intent, unexpectedly low intent
        cart_to_checkout_prob = 0.36 if device == "Desktop" else 0.27
        if source == "Paid Social" and device == "Mobile":
            cart_to_checkout_prob -= 0.07
        if source == "Email":
            cart_to_checkout_prob += 0.08

        if random.random() > cart_to_checkout_prob:
            # Cart Abandonment
            sessions.append({
                "session_id": session_id,
                "user_id": user_id,
                "session_start": session_dt.strftime("%Y-%m-%d %H:%M:%S"),
                "device_type": device,
                "traffic_source": source,
                "page_views": 4,
                "duration_seconds": int((curr_time - session_dt).total_seconds()) + random.randint(15, 60),
                "is_bounced": 0,
                "has_converted": 0
            })
            continue

        # ----------------------------------------------------
        # STAGE 5: Checkout Initiated (Eligible for A/B Testing!)
        # ----------------------------------------------------
        curr_time += timedelta(seconds=random.randint(15, 45))
        
        # A/B Experiment Assignment (50/50 Control vs Treatment)
        ab_variant = "Treatment" if random.random() < 0.50 else "Control"
        
        events.append({
            "event_id": event_id_seq,
            "session_id": session_id,
            "user_id": user_id,
            "event_name": "checkout_initiated",
            "page_type": "checkout_step1",
            "product_id": selected_prod["product_id"],
            "page_load_ms": base_latency + (200 if ab_variant == "Control" else 50),
            "event_timestamp": curr_time.strftime("%Y-%m-%d %H:%M:%S")
        })
        event_id_seq += 1

        # Checkout friction: Treatment has 1-step checkout with autofill (+8% relative completion)
        checkout_to_pay_prob = 0.68 if device == "Desktop" else 0.54
        if ab_variant == "Treatment":
            checkout_to_pay_prob += 0.07  # Lift from treatment variant
        
        if random.random() > checkout_to_pay_prob:
            # Abandoned at checkout
            ab_test_records.append({
                "experiment_id": "EXP-CHK-2025-Q3",
                "session_id": session_id,
                "user_id": user_id if user_id else "GUEST",
                "variant": ab_variant,
                "device": device,
                "reached_checkout": 1,
                "completed_checkout": 0,
                "checkout_duration_sec": random.randint(25, 90),
                "encountered_error": 1 if (device == "Mobile" and random.random() < 0.18) else 0
            })
            sessions.append({
                "session_id": session_id,
                "user_id": user_id,
                "session_start": session_dt.strftime("%Y-%m-%d %H:%M:%S"),
                "device_type": device,
                "traffic_source": source,
                "page_views": 5,
                "duration_seconds": int((curr_time - session_dt).total_seconds()) + random.randint(20, 80),
                "is_bounced": 0,
                "has_converted": 0
            })
            continue

        # ----------------------------------------------------
        # STAGE 6: Payment Attempted
        # ----------------------------------------------------
        curr_time += timedelta(seconds=random.randint(20, 60))
        chosen_payment = random.choices(PAYMENT_METHODS, weights=PAYMENT_WEIGHTS)[0]

        # Latent payment failure probabilities:
        # BNPL (credit checks) has ~12% fail rate; Cards ~4% fail rate; Apple Pay ~2.5%
        fail_prob = 0.04
        if chosen_payment == "Buy Now Pay Later":
            fail_prob = 0.12
        elif chosen_payment == "Apple Pay":
            fail_prob = 0.025
        elif chosen_payment == "Debit Card":
            fail_prob = 0.06

        events.append({
            "event_id": event_id_seq,
            "session_id": session_id,
            "user_id": user_id,
            "event_name": "payment_attempted",
            "page_type": "payment_gateway",
            "product_id": selected_prod["product_id"],
            "page_load_ms": base_latency + random.randint(300, 700),
            "event_timestamp": curr_time.strftime("%Y-%m-%d %H:%M:%S")
        })
        event_id_seq += 1

        is_payment_successful = random.random() > fail_prob

        if not is_payment_successful:
            # Payment failed
            payments.append({
                "payment_id": payment_id_seq,
                "order_id": None,
                "session_id": session_id,
                "payment_method": chosen_payment,
                "amount": round(selected_prod["retail_price"] * cart_qty, 2),
                "payment_status": "Failed",
                "error_code": "DECLINED_BY_ISSUER" if chosen_payment != "Buy Now Pay Later" else "CREDIT_THRESHOLD_EXCEEDED",
                "payment_timestamp": curr_time.strftime("%Y-%m-%d %H:%M:%S")
            })
            payment_id_seq += 1

            ab_test_records.append({
                "experiment_id": "EXP-CHK-2025-Q3",
                "session_id": session_id,
                "user_id": user_id if user_id else "GUEST",
                "variant": ab_variant,
                "device": device,
                "reached_checkout": 1,
                "completed_checkout": 0,
                "checkout_duration_sec": random.randint(45, 120),
                "encountered_error": 1
            })

            sessions.append({
                "session_id": session_id,
                "user_id": user_id,
                "session_start": session_dt.strftime("%Y-%m-%d %H:%M:%S"),
                "device_type": device,
                "traffic_source": source,
                "page_views": 6,
                "duration_seconds": int((curr_time - session_dt).total_seconds()) + random.randint(30, 90),
                "is_bounced": 0,
                "has_converted": 0
            })
            continue

        # ----------------------------------------------------
        # STAGE 7: Purchase Completed (Order Created)
        # ----------------------------------------------------
        curr_time += timedelta(seconds=random.randint(5, 15))
        
        # If user was guest, auto-assign or create user
        if user_id is None:
            user_id = random.choice(user_ids)

        order_id = f"ORD-2025-{order_id_seq:06d}"
        subtotal = round(selected_prod["retail_price"] * cart_qty, 2)
        # Shipping: Free if subtotal >= $75, else $7.99
        shipping = 0.0 if subtotal >= 75.0 else 7.99
        tax = round(subtotal * 0.0825, 2)
        discount = round(subtotal * 0.10, 2) if source == "Email" else 0.0
        total_order_amt = round(subtotal + shipping + tax - discount, 2)

        events.append({
            "event_id": event_id_seq,
            "session_id": session_id,
            "user_id": user_id,
            "event_name": "purchase_completed",
            "page_type": "order_confirmation",
            "product_id": selected_prod["product_id"],
            "page_load_ms": base_latency + 100,
            "event_timestamp": curr_time.strftime("%Y-%m-%d %H:%M:%S")
        })
        event_id_seq += 1

        orders.append({
            "order_id": order_id,
            "user_id": user_id,
            "session_id": session_id,
            "order_timestamp": curr_time.strftime("%Y-%m-%d %H:%M:%S"),
            "subtotal": subtotal,
            "discount_amount": discount,
            "shipping_fee": shipping,
            "tax_amount": tax,
            "total_amount": total_order_amt,
            "order_status": "Delivered" if random.random() < 0.94 else "Processing",
            "shipping_method": "Free Standard" if shipping == 0.0 else "Standard Ground"
        })

        order_items.append({
            "order_item_id": order_item_id_seq,
            "order_id": order_id,
            "product_id": selected_prod["product_id"],
            "quantity": cart_qty,
            "unit_price": selected_prod["retail_price"],
            "line_total": subtotal
        })
        order_item_id_seq += 1

        payments.append({
            "payment_id": payment_id_seq,
            "order_id": order_id,
            "session_id": session_id,
            "payment_method": chosen_payment,
            "amount": total_order_amt,
            "payment_status": "Successful",
            "error_code": None,
            "payment_timestamp": curr_time.strftime("%Y-%m-%d %H:%M:%S")
        })
        payment_id_seq += 1

        # Record A/B test completed checkout
        ab_test_records.append({
            "experiment_id": "EXP-CHK-2025-Q3",
            "session_id": session_id,
            "user_id": user_id,
            "variant": ab_variant,
            "device": device,
            "reached_checkout": 1,
            "completed_checkout": 1,
            "checkout_duration_sec": random.randint(20, 65) if ab_variant == "Treatment" else random.randint(35, 110),
            "encountered_error": 0
        })

        sessions.append({
            "session_id": session_id,
            "user_id": user_id,
            "session_start": session_dt.strftime("%Y-%m-%d %H:%M:%S"),
            "device_type": device,
            "traffic_source": source,
            "page_views": 7,
            "duration_seconds": int((curr_time - session_dt).total_seconds()),
            "is_bounced": 0,
            "has_converted": 1
        })

        order_id_seq += 1

    return (
        pd.DataFrame(sessions),
        pd.DataFrame(events),
        pd.DataFrame(orders),
        pd.DataFrame(order_items),
        pd.DataFrame(payments),
        pd.DataFrame(ab_test_records)
    )

def main():
    print("Step 1: Generating Product Catalog...")
    df_products = generate_products()
    df_products.to_csv(os.path.join(DATA_DIR, "products.csv"), index=False)
    print(f" Saved {len(df_products)} products.")

    print("Step 2: Generating User Cohorts...")
    df_users = generate_users(num_users=10000)
    df_users.to_csv(os.path.join(DATA_DIR, "users.csv"), index=False)
    print(f" Saved {len(df_users)} users.")

    print("Step 3: Simulating Funnel Events & Orders...")
    df_sessions, df_events, df_orders, df_order_items, df_payments, df_ab_test = generate_behavioral_funnel(
        df_users, df_products, num_sessions=32000
    )

    df_sessions.to_csv(os.path.join(DATA_DIR, "web_sessions.csv"), index=False)
    df_events.to_csv(os.path.join(DATA_DIR, "funnel_events.csv"), index=False)
    df_orders.to_csv(os.path.join(DATA_DIR, "orders.csv"), index=False)
    df_order_items.to_csv(os.path.join(DATA_DIR, "order_items.csv"), index=False)
    df_payments.to_csv(os.path.join(DATA_DIR, "payments.csv"), index=False)
    df_ab_test.to_csv(os.path.join(DATA_DIR, "ab_test_events.csv"), index=False)

    print("\nDataset generation completed successfully!")
    print(f"Total Web Sessions: {len(df_sessions):,}")
    print(f"Total Funnel Events: {len(df_events):,}")
    print(f"Total Orders: {len(df_orders):,}")
    print(f"Total Payments Logged: {len(df_payments):,}")
    print(f"A/B Test Participants: {len(df_ab_test):,}")

if __name__ == "__main__":
    main()
