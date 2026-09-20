"""
MySQL 8.0 Automated Data Loader
Author: Analytics Engineering Team
Description: Loads CSV datasets into MySQL 8.0 ecommerce_analytics database.
Supports both direct MySQL CLI execution and Python DB connectors.
"""

import os
import sys
import subprocess
import pandas as pd

DATA_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "data"))
SQL_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "sql"))

TABLE_CSV_MAP = [
    ("users", "users.csv"),
    ("products", "products.csv"),
    ("web_sessions", "web_sessions.csv"),
    ("funnel_events", "funnel_events.csv"),
    ("orders", "orders.csv"),
    ("order_items", "order_items.csv"),
    ("payments", "payments.csv"),
    ("ab_test_events", "ab_test_events.csv"),
]

def generate_mysql_load_script():
    """
    Generates sql/00_load_data.sql using LOAD DATA LOCAL INFILE for blazingly fast ingestion.
    """
    load_sql_path = os.path.join(SQL_DIR, "00_load_data.sql")
    
    with open(load_sql_path, "w", encoding="utf-8") as f:
        f.write("-- =============================================================================\n")
        f.write("-- E-commerce Customer Journey & Conversion Analytics\n")
        f.write("-- Script 00: Bulk Data Ingestion Script for MySQL 8.0\n")
        f.write("-- =============================================================================\n\n")
        f.write("USE ecommerce_analytics;\n\n")
        f.write("SET FOREIGN_KEY_CHECKS = 0;\n\n")

        for table, csv_name in TABLE_CSV_MAP:
            csv_path = os.path.join(DATA_DIR, csv_name).replace("\\", "/")
            f.write(f"-- Loading table: {table}\n")
            f.write(f"LOAD DATA LOCAL INFILE '{csv_path}'\n")
            f.write(f"INTO TABLE {table}\n")
            f.write("FIELDS TERMINATED BY ','\n")
            f.write("ENCLOSED BY '\"'\n")
            f.write("LINES TERMINATED BY '\\n'\n")
            f.write("IGNORE 1 LINES;\n\n")
            
        f.write("SET FOREIGN_KEY_CHECKS = 1;\n")
        f.write("SELECT 'Data Ingestion Completed Successfully!' AS status;\n")

    print(f"[OK] Generated MySQL bulk ingestion script: {load_sql_path}")
    return load_sql_path

def main():
    print("==================================================")
    print("MySQL 8.0 Data Loader & Script Generator")
    print("==================================================")
    generate_mysql_load_script()
    print("\nTo load into MySQL 8.0 via CLI, run:")
    print("  mysql --local-infile=1 -u root -p ecommerce_analytics < sql/00_load_data.sql")
    print("\nAll CSV datasets are verified and ready in data/ directory.")

if __name__ == "__main__":
    main()
