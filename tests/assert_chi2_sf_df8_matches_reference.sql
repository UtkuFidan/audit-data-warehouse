-- The closed-form chi-square survival function (8 degrees of freedom) against textbook critical
-- values: 15.507 -> 0.05, 20.090 -> 0.01, 26.124 -> 0.001. Returns rows only when one is off.
select
    x,
    expected,
    {{ chi2_sf_df8('x') }} as actual
from (
    values (15.507, 0.05), (20.090, 0.01), (26.124, 0.001)
) as t (x, expected)
where abs({{ chi2_sf_df8('x') }} - expected) > expected * 0.01
