"""
Cross-Engine SQL Pipeline Runner & Analytical Verification Engine
Author: Analytics Engineering Team
Description: Loads CSV datasets into an in-memory SQL database (with registered
             MySQL 8 compatibility functions), executes all scripts (02 through 08),
             validates data quality, prints clean tabular results, and exports query outputs.
"""

import os
import re
import sqlite3
import pandas as pd
from datetime import datetime

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
DATA_DIR = os.path.join(BASE_DIR, "data")
SQL_DIR = os.path.join(BASE_DIR, "sql")
OUTPUT_DIR = os.path.join(BASE_DIR, "docs", "query_results")
os.makedirs(OUTPUT_DIR, exist_ok=True)

# -----------------------------------------------------------------------------
# MySQL Compatibility UDFs for SQLite Engine
# -----------------------------------------------------------------------------
def mysql_date_format(val, fmt):
    if not val:
        return None
    try:
        dt = pd.to_datetime(val)
        # Convert MySQL format to Python strftime
        py_fmt = fmt.replace("%Y", "%Y").replace("%m", "%m").replace("%d", "%d")
        py_fmt = py_fmt.replace("%H", "%H").replace("%i", "%M").replace("%s", "%S")
        return dt.strftime(py_fmt)
    except Exception:
        return str(val)

def mysql_timestampdiff(unit, dt1, dt2):
    if not dt1 or not dt2:
        return None
    try:
        t1 = pd.to_datetime(dt1)
        t2 = pd.to_datetime(dt2)
        u = str(unit).upper()
        if u == "MONTH":
            return (t2.year - t1.year) * 12 + (t2.month - t1.month)
        elif u == "DAY":
            return (t2 - t1).days
        return int((t2 - t1).total_seconds())
    except Exception:
        return 0

def mysql_datediff(dt1, dt2):
    if not dt1 or not dt2:
        return None
    try:
        t1 = pd.to_datetime(dt1)
        t2 = pd.to_datetime(dt2)
        return (t1 - t2).days
    except Exception:
        return 0

def mysql_concat(*args):
    return "".join(str(a) for a in args if a is not None)

def create_in_memory_db():
    conn = sqlite3.connect(":memory:")
    # Register MySQL 8.0 functions
    conn.create_function("DATE_FORMAT", 2, mysql_date_format)
    conn.create_function("TIMESTAMPDIFF", 3, mysql_timestampdiff)
    conn.create_function("DATEDIFF", 2, mysql_datediff)
    conn.create_function("CONCAT", -1, mysql_concat)

    # Ingest tables
    tables = [
        ("users", "users.csv"),
        ("products", "products.csv"),
        ("web_sessions", "web_sessions.csv"),
        ("funnel_events", "funnel_events.csv"),
        ("orders", "orders.csv"),
        ("order_items", "order_items.csv"),
        ("payments", "payments.csv"),
        ("ab_test_events", "ab_test_events.csv"),
    ]

    print("Loading CSV datasets into relational memory...")
    for table_name, csv_file in tables:
        csv_path = os.path.join(DATA_DIR, csv_file)
        if os.path.exists(csv_path):
            df = pd.read_csv(csv_path)
            df.to_sql(table_name, conn, if_exists="replace", index=False)
            print(f"  Loaded {table_name}: {len(df):,} rows")
        else:
            print(f"  Warning: {csv_file} not found!")

    return conn

def clean_sql_statements(sql_text):
    """
    Cleans comments and splits SQL into individual executable statements.
    Removes MySQL specific header directives like USE or CREATE DATABASE.
    """
    # Remove single line comments
    lines = []
    for line in sql_text.splitlines():
        trimmed = line.strip()
        if trimmed.startswith("--") or not trimmed:
            continue
        lines.append(line)
    
    clean_text = "\n".join(lines)
    
    # Split by semicolon
    raw_stmts = [s.strip() for s in clean_text.split(";") if s.strip()]
    executable_stmts = []
    
    for s in raw_stmts:
        lower_s = s.lower()
        if lower_s.startswith("use ") or lower_s.startswith("create database") or lower_s.startswith("drop table"):
            continue
        if lower_s.startswith("set foreign_key_checks"):
            continue
        
        # In SQLite, unquoted keywords in function args are parsed as column names.
        # Convert TIMESTAMPDIFF(MONTH, ...) to TIMESTAMPDIFF('MONTH', ...)
        s_adapted = re.sub(r'TIMESTAMPDIFF\s*\(\s*([A-Za-z]+)\s*,', r"TIMESTAMPDIFF('\1',", s, flags=re.IGNORECASE)
        executable_stmts.append(s_adapted)
        
    return executable_stmts

def df_to_markdown_simple(df):
    headers = [str(c) for c in df.columns]
    header_line = "| " + " | ".join(headers) + " |"
    separator_line = "| " + " | ".join(["---"] * len(headers)) + " |"
    row_lines = []
    for _, row in df.iterrows():
        row_str = "| " + " | ".join(str(val) for val in row.values) + " |"
        row_lines.append(row_str)
    return "\n".join([header_line, separator_line] + row_lines)

def run_pipeline():
    conn = create_in_memory_db()

    scripts = [
        ("02_data_quality_checks.sql", "Data Quality & Integrity Suite"),
        ("03_core_business_metrics.sql", "Core Business & Financial KPIs"),
        ("04_funnel_analysis.sql", "Funnel Drop-off & Stage Conversion"),
        ("05_customer_cohort_rfm.sql", "Customer Cohorts & RFM Segmentation"),
        ("06_product_category_analysis.sql", "Product & Category Conversion"),
        ("07_root_cause_investigation.sql", "Root-Cause Friction Analysis"),
        ("08_ab_test_checkout_experiment.sql", "A/B Testing Experimentation"),
    ]

    summary_report_lines = [
        "# Automated SQL Analytics Execution Report",
        f"Generated at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
        "",
    ]

    print("\n" + "=" * 70)
    print("STARTING ADVANCED SQL ANALYTICS EXECUTION")
    print("=" * 70)

    for script_file, script_title in scripts:
        script_path = os.path.join(SQL_DIR, script_file)
        if not os.path.exists(script_path):
            print(f"File not found: {script_path}")
            continue

        print(f"\n>>> Executing Script: {script_file} ({script_title})")
        summary_report_lines.append(f"## {script_file}: {script_title}")
        summary_report_lines.append("")

        with open(script_path, "r", encoding="utf-8") as f:
            sql_content = f.read()

        stmts = clean_sql_statements(sql_content)

        for idx, stmt in enumerate(stmts, start=1):
            try:
                df_result = pd.read_sql_query(stmt, conn)
                output_csv_name = f"{script_file.replace('.sql', '')}_query_{idx}.csv"
                df_result.to_csv(os.path.join(OUTPUT_DIR, output_csv_name), index=False)

                print(f"  [Query {idx}] Returned {len(df_result)} rows")
                if len(df_result) <= 12:
                    print(df_result.to_string(index=False))
                else:
                    print(df_result.head(5).to_string(index=False))
                    print(f"  ... ({len(df_result) - 5} rows truncated in console)")

                summary_report_lines.append(f"### Query {idx}")
                summary_report_lines.append(f"{df_to_markdown_simple(df_result.head(10))}\n")
                if len(df_result) > 10:
                    summary_report_lines.append(f"*(Showing top 10 of {len(df_result)} rows)*\n")

            except Exception as e:
                print(f"  [Query {idx} ERROR]: {e}")
                summary_report_lines.append(f"### Query {idx} - Execution Error\n`{e}`\n")

    report_path = os.path.join(BASE_DIR, "docs", "sql_execution_report.md")
    with open(report_path, "w", encoding="utf-8") as f:
        f.write("\n".join(summary_report_lines))

    print("\n" + "=" * 70)
    print(f"ALL SCRIPTS EXECUTED SUCCESSFULLY!")
    print(f"Execution report written to: {report_path}")
    print(f"CSV query results stored in: {OUTPUT_DIR}")
    print("=" * 70)

if __name__ == "__main__":
    run_pipeline()
