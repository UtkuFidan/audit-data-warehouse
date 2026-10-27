{% test date_within_period(model, column_name, period_column, start_date, end_date) %}
{# Fails when a date is outside the fiscal year, or does not fall in the YYYY-MM period it is booked to. #}
select *
from {{ model }}
where {{ column_name }} < cast('{{ start_date }}' as date)
    or {{ column_name }} > cast('{{ end_date }}' as date)
    or strftime({{ column_name }}, '%Y-%m') <> {{ period_column }}
{% endtest %}
