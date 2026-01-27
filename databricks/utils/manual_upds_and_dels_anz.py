# Reminder: Apply the same structures to other banks
from pyspark.sql import DataFrame
from pyspark.sql.functions import col, lit, upper, when
from functools import reduce

# Manual overrides for edge cases the lookup rules miss (order matters)
MANUAL_UPDATES = [
    {
        "condition": (col("Description").like(upper(lit("%JB HI FI CHADSTONE%")))) & (col("Date") == "2025-11-05"),
        "updates": {"note": "refund"},
    },
    {
        "condition": col("Description").like(upper(lit("%FISHBALL PTY LTD%"))),
        "updates": {"category": "Groceries", "cleaned_desc": "FISHBALL PTY LTD PRESTON"},
    },
    # ...
]

# Manual removals for known bad/duplicate rows
MANUAL_DELETES = [
    (col("Description").like(upper(lit("%DOWNTOWN GROCER%MELBOURNE%")))) & (col("Amount") == 0.2),
    (col("Description").like(upper(lit("%USA CANDY STORES CARNEGIE%")))),
]

def anz_manual_updates(df: DataFrame) -> DataFrame:
    """Apply MANUAL_UPDATES (set specific columns when condition matches)."""
    for rule in MANUAL_UPDATES:
        cond = rule["condition"]
        for c, v in rule["updates"].items():
            df = df.withColumn(c, when(cond, lit(v)).otherwise(col(c)))
    return df

def anz_manual_deletes(df: DataFrame) -> DataFrame:
    """Remove rows matching any MANUAL_DELETES condition."""
    if not MANUAL_DELETES:
        return df
    delete_cond = reduce(lambda a, b: a | b, MANUAL_DELETES)
    return df.filter(~delete_cond)
