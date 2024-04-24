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

    summary as (

        select
            gs.game_id game_id,
            gs.date date,
            gs.home_team home_team,
            gs.away_team away_team,
            sum(case when gb.team_name == gs.home_team then gb.points else 0 end) home_team_points,
            sum(case when gb.team_name == gs.away_team then gb.points else 0 end) away_team_points,
            gs.date between sc.start_date and sc.end_date is_regular_season

        from game_schedule gs

        inner join game_boxscore gb on gb.game_id = gs.game_id
        inner join season_calendar sc on sc.year = gs.season_year

        group by gs.game_id, gs.date, gs.home_team, gs.away_team, sc.start_date, sc.end_date

    ),

    final as (

        select
            s.game_id game_id,
            s.date date,
            s.home_team home_team,
            s.away_team away_team,
            s.home_team_points home_team_points,
            s.away_team_points away_team_points,
            s.is_regular_season is_regular_season,
            case when s.home_team_points > s.away_team_points then s.home_team else s.away_team end winning_team,
            case when s.home_team_points > s.away_team_points then s.away_team else s.home_team end losing_team

        from summary s

        order by s.date, s.home_team

    )

select *

from final
