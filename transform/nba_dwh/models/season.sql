{{
    config(
        materialized="table",
        tags=["gold"],
    )
}}


with
    season_calendar as (select * from {{ source("local_source", "season_calendar") }}),

    final as (

        select
            sha256(sc.year::varchar) id,
            concat(
                date_part('year', sc.start_date::date)::varchar, '-', date_part('year', sc.end_date::date)::varchar
            ) as years,
            sc.start_date::date start_date,
            sc.end_date::date end_date,
            date_part('year', sc.start_date::date) start_year,
            date_part('year', sc.end_date::date) end_year

        from season_calendar sc

    )

select *
from final
