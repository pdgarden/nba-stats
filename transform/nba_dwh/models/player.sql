{{ config(materialized="table", tags=["gold"], docs={"node_color": "gold"}) }}

with
    game_boxscore as (select * from {{ ref("game_boxscore") }}),

    final as (
        select distinct sha256(gb.player_name) id, gb.player_name player_name
        from game_boxscore gb
        order by gb.player_name
    )

select *
from final
