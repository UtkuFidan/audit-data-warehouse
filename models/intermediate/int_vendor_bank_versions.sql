-- Slowly changing dimension type 2, modelled from the bank-change log.
-- One row per vendor and bank-detail version; valid_to is exclusive (9999-12-31 for current).
with first_change as (
    select
        vendor_id,
        arg_min(old_bank_iban, change_date) as original_iban
    from {{ ref('stg_vendor_bank_changes') }}
    group by vendor_id
),

versions as (
    select
        v.vendor_id,
        coalesce(fc.original_iban, v.current_bank_iban) as bank_iban,
        v.created_date as valid_from
    from {{ ref('stg_vendors') }} as v
    left join first_change as fc on v.vendor_id = fc.vendor_id

    union all

    select
        vendor_id,
        new_bank_iban as bank_iban,
        change_date as valid_from
    from {{ ref('stg_vendor_bank_changes') }}
)

select
    vendor_id,
    bank_iban,
    valid_from,
    coalesce(
        lead(valid_from) over (partition by vendor_id order by valid_from),
        date '9999-12-31'
    ) as valid_to,
    row_number() over (partition by vendor_id order by valid_from) as version_number
from versions
