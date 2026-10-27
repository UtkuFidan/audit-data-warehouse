-- Full-population test bank_change_payment: payment to the new IBAN shortly after a bank-detail change.
-- If several changes qualify, the closest preceding one is reported.
with matched as (
    select
        pay.payment_id,
        pay.vendor_id,
        pay.payment_amount,
        bc.bank_change_id,
        bc.change_date,
        date_diff('day', bc.change_date, pay.payment_date) as days_after_change,
        row_number() over (partition by pay.payment_id order by bc.change_date desc) as rn
    from {{ ref('stg_payments') }} as pay
    inner join {{ ref('stg_vendor_bank_changes') }} as bc
        on
            pay.vendor_id = bc.vendor_id
            and pay.bank_iban = bc.new_bank_iban
            and pay.payment_date >= bc.change_date
    where date_diff('day', bc.change_date, pay.payment_date) <= {{ var('bank_window_days') }}
)

select
    'bank_change_payment' as test_id,
    payment_id as entity,
    'Payment diversion fraud' as risk,
    'Payment ' || payment_id || ' (' || format('{:.2f}', payment_amount) || ') to ' || vendor_id
    || ' ' || days_after_change || ' days after bank change ' || bank_change_id
    || ' on ' || cast(change_date as varchar) as evidence
from matched
where rn = 1
