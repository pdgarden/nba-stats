{{
    config(
        materialized="table",
        tags=["gold"],
    )
}}


with
    game_boxscore as (select * from {{ ref("game_boxscore") }}),

    game_schedule as (select * from {{ ref("base_game_schedule") }}),

    season_calendar as (select * from {{ source("local_source", "season_calendar") }}),

    summary as (

        select
            sha256(gs.game_id) id,
            gs.game_id game_name,
            gs.date date,
            sha256(gs.home_team) home_team_id,
            sha256(gs.away_team) away_team_id,
            gs.date between sc.start_date and sc.end_date is_regular_season,
            sum(case when gb.team_id == sha256(gs.home_team) then gb.points else 0 end) home_team_points,
            sum(case when gb.team_id == sha256(gs.away_team) then gb.points else 0 end) away_team_points

        from game_schedule gs

        inner join game_boxscore gb on gb.game_id = gs.game_id
        inner join season_calendar sc on sha256(sc.year::varchar) = sha256(gs.season_year::varchar)

        group by 1, 2, 3, 4, 5, 6

    ),

    final as (

        select
            s.id id,
            s.game_name game_name,
            s.date date,
            s.home_team_id home_team_id,
            s.away_team_id away_team_id,
            s.home_team_points home_team_points,
            s.away_team_points away_team_points,
            s.is_regular_season is_regular_season,
            case
                when s.home_team_points > s.away_team_points then s.home_team_id else s.away_team_id
            end winning_team_id,
            case when s.home_team_points > s.away_team_points then s.away_team_id else s.home_team_id end losing_team_id

        from summary s

        order by s.date, s.game_name

    )

select *

from final
