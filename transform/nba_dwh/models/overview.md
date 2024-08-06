{% docs __overview__ %}

## Description

This project focuses on modeling NBA data extracted from raw boxscores and season schedules. It leverages [dbt and duckdb](https://github.com/duckdb/dbt-duckdb).

The database is constructed locally using `local_source` containing parquet files, with data spanning from the 1998/1999 to the 2023/2024 season.

### Main Tables
- [player](#!/model/model.nba_dwh.player): Contains name of players.
- [player_season](#!/model/model.nba_dwh.player_season): Contains statistics per player and season.
- [team](#!/model/model.nba_dwh.team): Contains name of teams.
- [team_season](#!/model/model.nba_dwh.team_season): Contains statistics per team and season.
- [game_boxscore](#!/model/model.nba_dwh.game_boxscore): Contains the boxscore of each game.
- [game_summary](#!/model/model.nba_dwh.game_summary): Contains teams main statistics per game.


## Graph Exploration

- To visualize the lineage graph of every model, click the blue icon located in the bottom-right corner of the page.
- To filter out the concatenated sources (`game_boxscore_*` / `game_schedule_*`) which can overload the graph, you can add `tag:sources_concat` in the `--exclude` section.
- Additionally, you can right-click on models for interactive filtering and exploration.

{% enddocs %}
