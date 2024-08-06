{{
    config(
        materialized="table",
        tags=["gold"],
    )
}}

with
    game_boxscore as (select * from {{ ref("game_boxscore") }}),

    final as (select distinct id, gb.player_name player_name from game_boxscore gb order by gb.player_name)

select *
from final
