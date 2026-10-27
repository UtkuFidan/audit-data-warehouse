select
    cast(po_id as varchar) as po_id,
    cast(vendor_id as varchar) as vendor_id,
    cast(po_date as date) as po_date,
    cast(amount as decimal(18, 2)) as po_amount,
    cast(requester_id as varchar) as requester_user_id,
    cast(approver_id as varchar) as approver_user_id
from {{ source('raw', 'purchase_orders') }}
