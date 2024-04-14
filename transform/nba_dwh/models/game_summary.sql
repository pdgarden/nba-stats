{{
    config(
        materialized='external',
        location='output/game_summary.csv',
        tags=['gold'],
    )
}}


with game_boxscore as (

    select * from {{ ref('game_boxscore') }}

),


game_schedule as (

    select * from {{ ref('2023_game_schedule') }}

),

final as (

    select
        gs.game_id game_id,
        gs.basketball_reference_url, -- TODO remove
        gs.date date,
        gs.home_team home_team,
        gs.away_team away_team,
        sum(case when gb.team_name == gs.home_team then gb.points else 0 end) home_team_points,
        sum(case when gb.team_name == gs.away_team then gb.points else 0 end) away_team_points,
        (
            sum(case when gb.team_name == gs.home_team then gb.points else 0 end)
            >
            sum(case when gb.team_name == gs.away_team then gb.points else 0 end)
        ) home_team_won

    from game_schedule gs

    inner join game_boxscore gb on gb.game_id = gs.game_id

    group by gs.game_id, gs.date, gs.home_team, gs.away_team
,gs.basketball_reference_url
)

select * from final
