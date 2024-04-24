{{
    config(
        materialized="external",
        location="output/team_season.csv",
        tags=["gold"],
    )
}}


with
    game_summary as (select * from {{ ref("game_summary") }}),

    team as (select distinct home_team id from game_summary),

    game_schedule as (select * from {{ ref("base_game_schedule") }}),

    game_summary_home as (

        select *, gs.winning_team = gs.home_team won_game, team.id team_id

        from game_summary gs

        inner join team on team.id = gs.home_team

    ),

    game_summary_away as (

        select *, gs.winning_team = gs.away_team won_game, team.id team_id

        from game_summary gs
        inner join team on team.id = gs.away_team

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
            gss.team_id,
            gs.season_year,
            count(*) nb_game,
            sum(won_game::int) nb_game_win,
            avg(won_game::int) pct_game_win

        from game_summary_stack gss

        inner join game_schedule gs on gs.game_id = gss.game_id

        where gss.is_regular_season

        group by gss.team_id, gs.season_year

        order by gss.team_id, gs.season_year

    )

select *
from final
