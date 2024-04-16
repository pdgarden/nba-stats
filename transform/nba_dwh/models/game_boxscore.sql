{{
    config(
        materialized='external',
        location='output/game_boxscore.csv',
        tags=['gold'],
    )
}}


with game_boxscore as (

    select * from {{ ref('2024_game_boxscore') }}

),

final as (

    select
        sha256(gb.game_id::varchar || gb.team::varchar || gb.Starters) id,
        gb.game_id::VARCHAR game_id,
        gb.team::VARCHAR team_name,
        gb.Starters::VARCHAR player_name,
        (string_split(gb.MP, ':')[1]::float + (string_split(gb.MP, ':')[2]::float / 60))::float minute_played,
        gb.FG::int field_goals_made,
        gb.FGA field_goals_attempts,
        #5::float field_goals_pct,
        #6::int three_pts_made,
        #7::int three_pts_attempts,
        #8::float three_pts_pct,
        gb.FT::int free_throw_made,
        gb.FTA::int free_throw_attempts,
        #11::float free_throw_pct,
        gb.ORB::int offensive_rebounds,
        gb.DRB::int defensive_rebounds,
        gb.TRB::int total_rebounds,
        gb.AST::int assists,
        gb.STL::int steals,
        gb.BLK::int blocks,
        gb.TOV::int turnovers,
        gb.PF::int fouls,
        gb.PTS::int points,
        #21::int plus_minus
    from game_boxscore gb

    where gb.Starters not in ('Starters', 'Reserves') -- remove headers
        and gb.MP like '%:%' --the player played the game

)

select * from final
