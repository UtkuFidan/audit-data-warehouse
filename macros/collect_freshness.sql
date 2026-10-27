{# Source freshness against the as_of_date var instead of the wall clock.
   Overrides dbt's global macro of the same name; the signature and the three returned columns
   are what `dbt source freshness` expects. Override the cut-off with --vars '{as_of_date: ...}'. #}
{% macro collect_freshness(source, loaded_at_field, filter) -%}
    {% call statement('collect_freshness', fetch_result=True, auto_begin=False) -%}
        select
            max({{ loaded_at_field }}) as max_loaded_at,
            cast('{{ var("as_of_date") }}' as timestamp) as snapshotted_at
        from {{ source }}
        {% if filter %}
        where {{ filter }}
        {% endif %}
    {%- endcall %}
    {{ return(load_result('collect_freshness')) }}
{%- endmacro %}
