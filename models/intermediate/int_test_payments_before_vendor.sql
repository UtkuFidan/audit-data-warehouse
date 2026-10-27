-- Full-population test payment_before_vendor: a payment dated before the vendor master record
-- existed, which suggests back-dated vendor creation or a payment outside the vendor onboarding control.
select
    'payment_before_vendor' as test_id,
    p.payment_id as entity,
    'Vendor master control bypass' as risk,
    'Payment ' || p.payment_id || ' (' || format('{:.2f}', p.payment_amount) || ') to ' || p.vendor_id
    || ' dated ' || cast(p.payment_date as varchar) || ', ' || date_diff('day', p.payment_date, v.created_date)
    || ' days before the vendor was created on ' || cast(v.created_date as varchar) as evidence
from {{ ref('stg_payments') }} as p
inner join {{ ref('stg_vendors') }} as v on p.vendor_id = v.vendor_id
where p.payment_date < v.created_date
