{{
    config(
        materialized="table",
        tags=["bronze"],
    )
}}


{% set season_years = [2023, 2024] %}


with
    final as (
        {% for season_year in season_years %}
            select *
            from {{ source("local_source", "game_schedule_" ~ season_year) }}
            {% if not loop.last %}
                union all
            {% endif %}
        {% endfor %}
    )

select *
from final
