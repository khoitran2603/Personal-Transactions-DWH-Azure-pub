from pyspark.sql import Row, DataFrame
from pyspark.sql.types import StructType, StructField, StringType, DoubleType
from pyspark.sql.functions import col, to_date

# Manual transactions not present in bank exports (cash / recurring / fixes)
MANUAL_INSERTS = [
    # Example
    {
        "Date": "2025-12-01",
        "Type": "Income",
        "category": "Family Support",
        "note": None,
        "Amount": 3000.0,
        "cleaned_desc": None,
        "Description": None,
        "location": None,
        "bank": None,
        "payment": "On-site",
    },
    {
        "Date": "2025-12-07",
        "Type": "Expenses",
        "category": "Transportation",
        "note": "rideshare",
        "Amount": -10.76,
        "cleaned_desc": "UBER",
        "Description": None,
        "location": None,
        "bank": "commbank",
        "payment": "On-site",
    },
]

def manual_inserts(df: DataFrame) -> DataFrame:
    """Append MANUAL_INSERTS to df (idempotent: skip if already exists)."""
    if not MANUAL_INSERTS:
        return df

    spark = df.sparkSession

    # Schema matches master transaction columns
    manual_schema = StructType([
        StructField("Date", StringType(), True),
        StructField("Type", StringType(), True),
        StructField("category", StringType(), True),
        StructField("note", StringType(), True),
        StructField("Amount", DoubleType(), True),
        StructField("cleaned_desc", StringType(), True),
        StructField("Description", StringType(), True),
        StructField("location", StringType(), True),
        StructField("bank", StringType(), True),
        StructField("payment", StringType(), True),
    ])

    # Build manual dataframe from python dicts
    manual_df = spark.createDataFrame([Row(**r) for r in MANUAL_INSERTS], schema=manual_schema)

    # Align Date type with target df if needed
    if dict(df.dtypes).get("Date") == "date":
        manual_df = manual_df.withColumn("Date", to_date(col("Date")))

    # Idempotent key: avoid duplicates on rerun
    cond = (
        (df["Date"] == manual_df["Date"]) &
        (df["Amount"] == manual_df["Amount"]) &
        (df["Description"] == manual_df["Description"]) &
        (df["bank"] == manual_df["bank"])
    )

    # Keep only new manual rows, then union into df
    manual_new = manual_df.join(df, cond, "left_anti")
    return df.unionByName(manual_new, allowMissingColumns=True)
