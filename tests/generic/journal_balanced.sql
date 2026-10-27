{% test journal_balanced(model, column_name, amount_column, side_column) %}
{# Fails for each journal whose debits do not equal its credits. side_column holds 'D' or 'C'. #}
select {{ column_name }}
from {{ model }}
group by {{ column_name }}
having sum(case when {{ side_column }} = 'D' then {{ amount_column }} else 0 end)
    <> sum(case when {{ side_column }} = 'C' then {{ amount_column }} else 0 end)
{% endtest %}
