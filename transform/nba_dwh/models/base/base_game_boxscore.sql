{{
    config(
        materialized="table",
        tags=["bronze"],
    )
}}


{% set season_years = [
    1999,
    2000,
    2001,
    2002,
    2003,
    2004,
    2005,
    2006,
    2007,
    2008,
    2009,
    2010,
    2011,
    2012,
    2013,
    2014,
    2015,
    2016,
    2017,
    2018,
    2019,
    2020,
    2021,
    2022,
    2023,
    2024,
] %}


with
    final as (
        {% for season_year in season_years %}
            select *
            from {{ source("local_source", "game_boxscore_" ~ season_year) }}
            {% if not loop.last %}
                union all
            {% endif %}
        {% endfor %}
    )

select *
from final
