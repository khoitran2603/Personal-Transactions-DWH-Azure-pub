from pyspark.sql import DataFrame
from pyspark.sql.functions import *

# Rule-based enrichers: map raw bank Description -> cleaned_desc/category/location/note
# Notes:
# - Uses LIKE patterns (case-normalized with UPPER)
# - First match wins (order matters)
# - Fallback keeps original Description or returns None

class description_lookup:
    def apply(df):
        return (
            df.withColumn(
                "cleaned_desc",
                # Merchant / description normalization
                when(col("Description").like(upper(lit("%7-ELEVEN%"))), "7-ELEVEN")
                # A
                .when(col("Description").like(upper(lit("%A & E SUNSHINE%"))), "A & E SUNSHINE BAKERY")
                .when(col("Description").like(upper(lit("%AAMI%"))), "AAMI")
                # ...
                .otherwise(col("Description"))  # fallback
            )
        )

class category_lookup:
    def apply(df: DataFrame, in_col: str = "Description") -> DataFrame:
        c = col(in_col)
        return (
            df.withColumn(
                "category",
                # Spending category classification
                when(c.like(upper(lit("%ORIENTAL TRADING%CLAYTON%"))), "Groceries")
                # ...
                .otherwise(None)  # unknown
            )
        )

class location_lookup:
    def apply(df: DataFrame, in_col: str = "Description") -> DataFrame:
        c = col(in_col)
        return (
            df.withColumn(
                "location",
                # Merchant -> location (or 'online')
                when(c.like(upper(lit("%BANHMI ON BELL%"))), "143 Bell St, Preston, Victoria 3072")
                # ...
                .otherwise(None)
            )
        )

class note_lookup:
    def apply(df: DataFrame, in_col: str = "Description") -> DataFrame:
        c = col(in_col)
        return (
            df.withColumn(
                "note",
                # Extra labels (e.g., asian supermarket / fast food)
                when(c.like(upper(lit("%ASIAN FOOD STORE%"))), "asian supermarket")
                # ...
                .otherwise(None)
            )
        )
