{% test positive_amount(model, column_name) %}
{# Fails for every row whose amount is null, zero or negative. #}
select *
from {{ model }}
where {{ column_name }} is null or {{ column_name }} <= 0
{% endtest %}
