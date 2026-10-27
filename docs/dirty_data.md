# Dirty-data run

`make dirty` copies `raw_extracts/` to `dirty_extracts/` (gitignored) with
`scripts/make_dirty_extracts.py`, injects six deliberate defects, then runs `dbt run` and `dbt test`
with `RAW_DIR=dirty_extracts` against a separate DuckDB file (`--target dirty`). Run and test are
separate commands because `dbt build` would skip every model downstream of a failing test and hide
the later failures.

| # | Defect injected | Caught by |
|---|---|---|
| 1 | `PAY-000010` amount set to -150.00 | `positive_amount` on `stg_payments`, `fct_payments` |
| 2 | One payment row duplicated with another amount | `unique` on `payment_id` (staging and mart) |
| 3 | `INV-000030` assigned to vendor `V9999`, absent from the master | `relationships` on `stg_invoices.vendor_id` |
| 4 | `JE-000100` posted on 2026-02-03 into period 2025-xx | `date_within_period` on `stg_gl_journal`, `fct_journal_entries` |
| 5 | `JE-000200` has no credit account | `not_null` on `credit_account`, `journal_balanced` on `int_journal_lines` |
| 6 | `U0005` status set to `SUSPENDED` | `accepted_values` on `stg_user_accounts`, `dim_user_access` |

Real output of the run (92 of 103 tests pass, 11 fail, every defect is caught at least once):

```text
FAIL 1 accepted_values_dim_user_access_account_status__ACTIVE__DISABLED  [FAIL 1 in 0.05s]
FAIL 1 accepted_values_stg_user_accounts_account_status__ACTIVE__DISABLED  [FAIL 1 in 0.04s]
FAIL 1 date_within_period_fct_journal_entries_posting_date___var_fiscal_year_end___fiscal_period___var_fiscal_year_start_  [FAIL 1 in 0.03s]
FAIL 1 date_within_period_stg_gl_journal_posting_date___var_fiscal_year_end___fiscal_period___var_fiscal_year_start_  [FAIL 1 in 0.06s]
FAIL 1 journal_balanced_int_journal_lines_amount__je_id__side [FAIL 1 in 0.07s]
FAIL 1 not_null_stg_gl_journal_credit_account [FAIL 1 in 0.06s]
FAIL 1 positive_amount_fct_payments_payment_amount [FAIL 1 in 0.04s]
FAIL 1 positive_amount_stg_payments_payment_amount [FAIL 1 in 0.06s]
FAIL 1 relationships_stg_invoices_vendor_id__vendor_id__ref_stg_vendors_  [FAIL 1 in 0.06s]
FAIL 1 unique_fct_payments_payment_id [FAIL 1 in 0.04s]
FAIL 1 unique_stg_payments_payment_id [FAIL 1 in 0.05s]
```

The clean extracts pass all 137 nodes (34 models, 103 tests).
