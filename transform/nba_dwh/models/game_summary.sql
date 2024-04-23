{{
    config(
        materialized="external",
        location="output/game_summary.csv",
        tags=["gold"],
    )
}}


with
    game_boxscore as (select * from {{ ref("game_boxscore") }}),

    game_schedule as (select * from {{ ref("base_game_schedule") }}),

    season_calendar as (select * from {{ source("local_source", "season_calendar") }}),

    final as (

        select
            gs.game_id game_id,
            gs.date date,
            gs.home_team home_team,
            gs.away_team away_team,
            sum(case when gb.team_name == gs.home_team then gb.points else 0 end) home_team_points,
            sum(case when gb.team_name == gs.away_team then gb.points else 0 end) away_team_points,
            (
                sum(case when gb.team_name == gs.home_team then gb.points else 0 end)
                > sum(case when gb.team_name == gs.away_team then gb.points else 0 end)
            ) home_team_won,
            gs.date between sc.start_date and sc.end_date is_regular_season

        from game_schedule gs

        inner join game_boxscore gb on gb.game_id = gs.game_id
        inner join season_calendar sc on sc.year = gs.season_year

        group by gs.game_id, gs.date, gs.home_team, gs.away_team, sc.start_date, sc.end_date

        order by gs.date, gs.home_team
    )

select *

from final
