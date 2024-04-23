{{
    config(
        materialized="external",
        location="output/player.csv",
        tags=["gold"],
    )
}}

with
    game_boxscore as (select * from {{ ref("game_boxscore") }}),

    game_schedule as (select * from {{ ref("base_game_schedule") }}),

    season_calendar as (select * from {{ source("local_source", "season_calendar") }}),

    final as (

        select
            sha256(gb.player_name || gs.season_year || gb.team_name) id,
            gb.player_name player_name,
            gs.season_year season_year,
            gb.team_name team_name,
            count(*) nb_games,
            sum(gb.minute_played) total_minute_played,
            sum(gb.field_goals_made) total_field_goals_made,
            sum(gb.field_goals_attempts) total_field_goals_attempts,
            sum(gb.three_pts_made) total_three_pts_made,
            sum(gb.three_pts_attempts) total_three_pts_attempts,
            sum(gb.free_throw_made) total_free_throw_made,
            sum(gb.free_throw_attempts) total_free_throw_attempts,
            sum(gb.offensive_rebounds) total_offensive_rebounds,
            sum(gb.defensive_rebounds) total_defensive_rebounds,
            sum(gb.total_rebounds) total_rebounds,
            sum(gb.assists) total_assists,
            sum(gb.steals) total_steals,
            sum(gb.blocks) total_blocks,
            sum(gb.turnovers) total_turnovers,
            sum(gb.fouls) total_fouls,
            sum(gb.points) total_points,
            sum(gb.plus_minus) total_plus_minus,
            avg(gb.minute_played) avg_minute_played,
            avg(gb.field_goals_made) avg_field_goals_made,
            avg(gb.field_goals_made) avg_field_goals_attempts,
            sum(gb.field_goals_made) / sum(gb.field_goals_attempts) avg_field_goals_pct,
            avg(gb.three_pts_made) avg_three_pts_made,
            avg(gb.three_pts_attempts) avg_three_pts_attempts,
            sum(gb.three_pts_made) / sum(gb.three_pts_attempts) avg_three_pts_pct,
            avg(gb.free_throw_made) avg_free_throw_made,
            avg(gb.free_throw_attempts) avg_free_throw_attempts,
            sum(gb.free_throw_made) / sum(gb.free_throw_attempts) avg_free_throw_pct,
            avg(gb.offensive_rebounds) avg_offensive_rebounds,
            avg(gb.defensive_rebounds) avg_defensive_rebounds,
            avg(gb.total_rebounds) avg_total_rebounds,
            avg(gb.assists) avg_assists,
            avg(gb.steals) avg_steals,
            avg(gb.blocks) avg_blocks,
            avg(gb.turnovers) avg_turnovers,
            avg(gb.fouls) avg_fouls,
            avg(gb.points) avg_points,
            avg(gb.plus_minus) avg_plus_minus

        from game_boxscore gb

        inner join game_schedule gs on gb.game_id = gs.game_id
        inner join season_calendar sc on sc.year = gs.season_year

        where gs.date between sc.start_date and sc.end_date

        group by gb.player_name, gs.season_year, gb.team_name

    )

select *
from final
