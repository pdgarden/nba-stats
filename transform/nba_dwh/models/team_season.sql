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

    game_summary_home as (

        select *, true is_home_team, home_team team_id

        from game_summary

        inner join team on team.id = game_summary.home_team

    ),

    game_summary_away as (

        select *, false is_home_team, away_team team_id

        from game_summary
        inner join team on team.id = game_summary.away_team

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
            count(*) nb_game,
            sum(
                ((gss.is_home_team and gss.home_team_won) or (not gss.is_home_team and not gss.home_team_won))::int
            ) nb_game_win,
            avg(
                ((gss.is_home_team and gss.home_team_won) or (not gss.is_home_team and not gss.home_team_won))::int
            ) pct_game_win

        from game_summary_stack gss

        where gss.is_regular_season

        group by gss.team_id

        order by gss.team_id

    )

select *
from final
