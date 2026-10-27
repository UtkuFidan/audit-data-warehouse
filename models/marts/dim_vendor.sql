{{ config(contract={'enforced': true}) }}

-- SCD2 vendor dimension: one row per vendor and bank-detail version.
select
    {{ dbt_utils.generate_surrogate_key(['v.vendor_id', 'b.valid_from']) }}::varchar as vendor_sk,
    v.vendor_id::varchar as vendor_id,
    v.vendor_name::varchar as vendor_name,
    v.country_code::varchar as country_code,
    v.tax_id::varchar as tax_id,
    b.bank_iban::varchar as bank_iban,
    b.version_number::integer as version_number,
    b.valid_from::date as valid_from,
    b.valid_to::date as valid_to,
    (b.valid_to = date '9999-12-31') as is_current
from {{ ref('stg_vendors') }} as v
inner join {{ ref('int_vendor_bank_versions') }} as b on v.vendor_id = b.vendor_id
