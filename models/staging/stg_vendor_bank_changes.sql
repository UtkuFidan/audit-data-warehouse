select
    cast(change_id as varchar) as bank_change_id,
    cast(vendor_id as varchar) as vendor_id,
    cast(change_date as date) as change_date,
    cast(old_iban as varchar) as old_bank_iban,
    cast(new_iban as varchar) as new_bank_iban,
    cast(changed_by as varchar) as changed_by_user_id
from {{ source('raw', 'vendor_bank_changes') }}
