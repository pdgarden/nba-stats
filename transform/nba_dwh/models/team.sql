{{ config(tags=["gold"], docs={"node_color": "gold"}) }}


with
    base_game_boxscore as (select * from {{ ref("base_game_boxscore") }}),

    final as (select distinct sha256(bgb.team) id, bgb.team team_name from base_game_boxscore bgb order by bgb.team)

select *
from final
