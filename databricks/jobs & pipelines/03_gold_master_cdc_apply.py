from pyspark import pipelines as dp
import dlt


expectations = {
  "rule_1": "transaction_id IS NOT NULL"
}


@dlt.table()
@dlt.expect_all_or_drop(expectations)

def master_stg_dlt():
        df = spark.readStream.table("budget_cata.gold.master_stg")
        return df
    

dlt.create_streaming_table(
  name = "master",
  expect_all_or_drop= expectations
)


dp.create_auto_cdc_flow(
  target = "master",
  source = "master_stg_dlt",
  keys = ["transaction_id"],
  sequence_by = "updated_at",
  stored_as_scd_type = 1,
  track_history_except_column_list = None,
  name = None,
  once = False
)