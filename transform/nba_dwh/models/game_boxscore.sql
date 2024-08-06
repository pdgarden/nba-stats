{{
    config(
        materialized="table",
        tags=["gold"],
    )
}}


with
    game_boxscore as (select * from {{ ref("base_game_boxscore") }}),

    final as (

        select
            sha256(gb.game_id::varchar || gb.team::varchar || gb.starters) id,
            sha256(gb.game_id::varchar) game_id,
            sha256(gb.team::varchar) team_id,
            sha256(gb.starters::varchar) player_id,
            gb.starters::varchar player_name,
            (string_split(gb.mp, ':')[1]::float + (string_split(gb.mp, ':')[2]::float / 60))::float minute_played,
            gb.fg::int field_goals_made,
            gb.fga field_goals_attempts,
            gb."FG%"::float field_goals_pct,
            gb."3P"::int three_pts_made,
            gb."3PA"::int three_pts_attempts,
            gb."3P%"::float three_pts_pct,
            gb.ft::int free_throw_made,
            gb.fta::int free_throw_attempts,
            gb."FT%"::float free_throw_pct,
            gb.orb::int offensive_rebounds,
            gb.drb::int defensive_rebounds,
            gb.trb::int total_rebounds,
            gb.ast::int assists,
            gb.stl::int steals,
            gb.blk::int blocks,
            gb.tov::int turnovers,
            gb.pf::int fouls,
            gb.pts::int points,
            gb."+/-"::int plus_minus
        from game_boxscore gb

        where
            gb.starters not in ('Starters', 'Reserves')  -- remove headers
            and gb.mp like '%:%'  -- the player played the game

    )

select *
from final
