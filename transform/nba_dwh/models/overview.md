{% docs __overview__ %}

## Description

This project focuses on modeling NBA data extracted from raw boxscores and season schedules. It leverages [dbt and duckdb](https://github.com/duckdb/dbt-duckdb).

The database is constructed locally using `local_source` containing parquet files, with data spanning from the 1998/1999 to the 2023/2024 season.

### Main Tables
- [player](#!/model/model.nba_dwh.player): Contains statistics per player and season.
- [game_boxscore](#!/model/model.nba_dwh.game_boxscore): Contains the boxscore of each game.
- [game_summary](#!/model/model.nba_dwh.game_summary): Contains teams main statistics per game.
- [team_season](#!/model/model.nba_dwh.team_season): Contains statistics per team and season.

## Graph Exploration

- To visualize the lineage graph of every model, click the blue icon located in the bottom-right corner of the page.
- On model pages, you'll find the immediate parents and children of the model you're exploring. By clicking the Expand button at the top-right of this lineage pane, you'll reveal all models used to build or built from the current model.
- Once expanded, you can utilize the `--select` and `--exclude` model selection syntax to filter the models in the graph. For more information on model selection, refer to the dbt docs.
- Additionally, you can right-click on models for interactive filtering and exploration.

{% enddocs %}
