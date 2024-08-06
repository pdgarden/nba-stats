{{
    config(
        materialized="table",
        tags=["gold"],
    )
}}


with
    game_summary as (select * from {{ ref("game_summary") }}),

    team as (select * from {{ ref("team") }}),

    game_schedule as (select * from {{ ref("base_game_schedule") }}),

    game_summary_home as (

        select *, gs.winning_team_id = gs.home_team_id won_game, team.id team_id

        from game_summary gs

        inner join team on team.id = gs.home_team_id

    ),

    game_summary_away as (

        select *, gs.winning_team_id = gs.away_team_id won_game, team.id team_id

        from game_summary gs
        inner join team on team.id = gs.away_team_id

    ),

    game_summary_stack as (
        select *
        from game_summary_home
        union all
        select *
        from game_summary_away

    ),

    final as (

        select
            sha256(gss.team_id || gs.season_year) id,
            gss.team_id,
            sha256(gs.season_year::varchar) season_id,
            count(*) nb_game,
            sum(won_game::int) nb_game_win,
            avg(won_game::int) pct_game_win

        from game_summary_stack gss

        inner join game_schedule gs on sha256(gs.game_id) = gss.id

        where gss.is_regular_season

        group by gss.team_id, gs.season_year

        order by gss.team_id, gs.season_year

    )

select *
from final
