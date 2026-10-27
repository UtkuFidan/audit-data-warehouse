{# Survival function (1 - cdf) of the chi-square distribution with 8 degrees of freedom.
   For an even number of degrees of freedom 2k it has a closed form,
   exp(-x/2) * sum_{j<k} (x/2)^j / j!, so the p-value needs no statistics library.
   The 9 Benford first digits give 8 degrees of freedom. #}
{% macro chi2_sf_df8(x) -%}
    (exp(-({{ x }}) / 2) * (1 + ({{ x }}) / 2 + power(({{ x }}) / 2, 2) / 2 + power(({{ x }}) / 2, 3) / 6))
{%- endmacro %}
