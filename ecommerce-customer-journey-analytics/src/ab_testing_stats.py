"""
Statistical Rigor Module: E-commerce Checkout A/B Experiment
Author: Product Analytics Team
Description: Computes two-proportion z-test, p-value, 95% confidence intervals,
             sample ratio mismatch (SRM) chi-square test, and guardrail metrics.
"""

import os
import math
import pandas as pd
import numpy as np
from scipy import stats

DATA_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "data"))

def evaluate_ab_test():
    csv_path = os.path.join(DATA_DIR, "ab_test_events.csv")
    if not os.path.exists(csv_path):
        print(f"Error: {csv_path} not found.")
        return

    df = pd.read_csv(csv_path)
    print("=====================================================================")
    print("           A/B TEST EVALUATION: EXPERIMENT EXP-CHK-2025-Q3           ")
    print("        One-Step Frictionless Checkout vs Standard Multi-Step        ")
    print("=====================================================================\n")

    # 1. Sample Sizes & Conversions
    ctrl = df[df["variant"] == "Control"]
    trmt = df[df["variant"] == "Treatment"]

    n_ctrl = len(ctrl)
    n_trmt = len(trmt)
    conv_ctrl = ctrl["completed_checkout"].sum()
    conv_trmt = trmt["completed_checkout"].sum()

    p_ctrl = conv_ctrl / n_ctrl
    p_trmt = conv_trmt / n_trmt
    diff = p_trmt - p_ctrl
    relative_uplift = (diff / p_ctrl) * 100.0

    print(f"Sample Sizes:")
    print(f"  • Control (A)   : {n_ctrl:,} users | Conversions: {conv_ctrl:,} ({p_ctrl*100:.2f}%)")
    print(f"  • Treatment (B) : {n_trmt:,} users | Conversions: {conv_trmt:,} ({p_trmt*100:.2f}%)")
    print(f"  • Absolute Lift : {diff*100:+.2f} percentage points")
    print(f"  • Relative Lift : {relative_uplift:+.2f}%\n")

    # 2. Sample Ratio Mismatch (SRM) Test (Chi-Square Goodness of Fit)
    total_n = n_ctrl + n_trmt
    expected = [total_n / 2.0, total_n / 2.0]
    observed = [n_ctrl, n_trmt]
    srm_chi2, srm_p = stats.chisquare(f_obs=observed, f_exp=expected)
    print(f"1. Sample Ratio Mismatch (SRM) Diagnostic:")
    print(f"   Chi2 Stat: {srm_chi2:.4f} | p-value: {srm_p:.4f}")
    if srm_p > 0.01:
        print("   [PASS] No evidence of Sample Ratio Mismatch (Randomization was fair).\n")
    else:
        print("   [WARNING] Potential SRM detected. Inspect traffic routing!\n")

    # 3. Two-Proportion Hypothesis Test (Z-Test)
    p_pool = (conv_ctrl + conv_trmt) / (n_ctrl + n_trmt)
    se_pool = math.sqrt(p_pool * (1.0 - p_pool) * (1.0 / n_ctrl + 1.0 / n_trmt))
    z_score = diff / se_pool
    p_value = 2.0 * (1.0 - stats.norm.cdf(abs(z_score)))

    # 95% Confidence Interval for Absolute Difference
    se_diff = math.sqrt((p_ctrl * (1.0 - p_ctrl) / n_ctrl) + (p_trmt * (1.0 - p_trmt) / n_trmt))
    ci_lower = (diff - 1.96 * se_diff) * 100.0
    ci_upper = (diff + 1.96 * se_diff) * 100.0

    print(f"2. Statistical Significance & Hypothesis Testing:")
    print(f"   Null Hypothesis (H0)       : Treatment Conversion == Control Conversion")
    print(f"   Alternative Hypothesis (H1): Treatment Conversion != Control Conversion")
    print(f"   Z-Score                    : {z_score:.4f}")
    print(f"   Two-Tailed p-value         : {p_value:.6f}")
    print(f"   95% Confidence Interval    : [{ci_lower:+.2f}%, {ci_upper:+.2f}%]")

    alpha = 0.05
    if p_value < alpha:
        print(f"   [CONCLUSION] Statistically Significant at alpha={alpha}. Reject H0 in favor of H1.\n")
    else:
        print(f"   [CONCLUSION] Not statistically significant at alpha={alpha}. Fail to reject H0.\n")

    # 4. Guardrail Metrics Evaluation
    ctrl_dur = ctrl["checkout_duration_sec"].mean()
    trmt_dur = trmt["checkout_duration_sec"].mean()
    ctrl_err = ctrl["encountered_error"].mean() * 100.0
    trmt_err = trmt["encountered_error"].mean() * 100.0

    print(f"3. Guardrail & User Experience Metrics:")
    print(f"   • Avg Checkout Duration: Control = {ctrl_dur:.1f}s vs Treatment = {trmt_dur:.1f}s ({trmt_dur - ctrl_dur:+.1f}s)")
    print(f"   • Error Encountered Rate: Control = {ctrl_err:.2f}% vs Treatment = {trmt_err:.2f}%\n")

    # 5. Device Sub-group Breakdown
    print(f"4. Device Segment Breakdown:")
    device_summary = df.groupby(["device", "variant"]).agg(
        total=("completed_checkout", "count"),
        conversions=("completed_checkout", "sum")
    ).reset_index()
    device_summary["conv_rate_pct"] = (device_summary["conversions"] / device_summary["total"]) * 100.0
    print(device_summary.to_string(index=False))
    print("=====================================================================\n")

if __name__ == "__main__":
    evaluate_ab_test()
