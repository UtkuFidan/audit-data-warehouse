-- Full-population test split_purchase: purchase orders just under the approval limit, raised by
-- the same requester on the same vendor within a short window, whose sum exceeds the limit.
with near_limit as (
    select *
    from {{ ref('stg_purchase_orders') }}
    where
        po_amount < {{ var('approval_limit') }}
        and po_amount >= {{ var('split_floor_ratio') }} * {{ var('approval_limit') }}
),

pairs as (
    select
        a.po_id as a_id,
        b.po_id as b_id
    from near_limit as a
    inner join near_limit as b
        on
            a.vendor_id = b.vendor_id
            and a.requester_user_id = b.requester_user_id
            and a.po_id < b.po_id
    where
        abs(date_diff('day', a.po_date, b.po_date)) <= {{ var('split_window_days') }}
        and a.po_amount + b.po_amount > {{ var('approval_limit') }}
),

members as (
    select
        a_id as po_id,
        b_id as partner_po_id
    from pairs
    union all
    select
        b_id as po_id,
        a_id as partner_po_id
    from pairs
)

select
    'split_purchase' as test_id,
    po.po_id as entity,
    'Approval-limit avoidance' as risk,
    'PO ' || po.po_id || ' (' || format('{:.2f}', po.po_amount) || ', requester '
    || po.requester_user_id || ', ' || po.vendor_id || ') split with '
    || string_agg(distinct m.partner_po_id, ', ' order by m.partner_po_id) as evidence
from members as m
inner join {{ ref('stg_purchase_orders') }} as po on m.po_id = po.po_id
group by po.po_id, po.po_amount, po.requester_user_id, po.vendor_id
