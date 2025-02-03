<img src="https://img.shields.io/static/v1?logo=python&label=python&message=3.12&logoColor=yellow&color=blue"> <img src="https://img.shields.io/static/v1?logo=dbt&label=dbt&message=1.9&color=blue"> <img src="https://img.shields.io/static/v1?logo=duckdb&label=duckdb&message=1.1&color=blue"> <img src="https://img.shields.io/static/v1?logo=uv&label=uv&message=0.5.10&color=blue">



# NBA stats

- [1. 💬 Project description](#1--project-description)
- [2. 📟 Prerequisites](#2--prerequisites)
- [3. 🔌 Quickstart](#3--quickstart)
- [4. 🚀 Run](#4--run)
  - [4.1. ⚙️ Scraping scripts](#41-️-scraping-scripts)
  - [4.2. ⚙️ Create database](#42-️-create-database)
  - [4.3. ⚙️ Interact with database](#43-️-interact-with-database)
- [5. 🔗 Internal Architecture](#5--internal-architecture)
- [6. 🏆 Code Quality and Formatting](#6--code-quality-and-formatting)
- [7. 📚 Complementary documentation](#7--complementary-documentation)


# 1. 💬 Project description

This project aims to build a local database for retrieving NBA data through SQL queries. It consists of two main parts:
- **Scraping**: To get raw data
- **Data engineering:** To manipulate the data using dbt & duckdb

Datawarehouse documentation: [link](https://pdgarden.github.io/nba-stats/)


# 2. 📟 Prerequisites

The project uses uv (`v0.5.10`) to handle python version and dependencies.


# 3. 🔌 Quickstart

To setup and use the project locally, execute the following steps:

1. `curl -LsSf https://astral.sh/uv/0.5.10/install.sh | sh` (Install uv `v0.5.10`. See [doc](https://docs.astral.sh/uv/getting-started/installation/).)
2. `uv sync` (Install virtual environment)
3. `uv run pre-commit install -t commit-msg -t pre-commit` (Setup pre-commit)


# 4. 🚀 Run

## 4.1. ⚙️ Scraping scripts
<details>
  <summary>This is not necessary to execute it again as the data is already extracted</summary>

- Generate `game_schedule.csv` : `uv run python -m scraping.get_games_schedule`
- Generate `game_boxscore.csv` : `uv run python -m scraping.get_games_boxscore`

> The generated data is then transferred to the sources of the dbt project: `cp ./scraping/data/*.parquet ./transform/nba_dwh/local_source/`

</details>

## 4.2. ⚙️ Create database

The following section describe the steps to create the local duckdb database, leveraging dbt:

1. `cd ./transform/nba_dwh`
2. `uv run dbt deps` (Install dbt dependencies)
3. `uv run dbt run` (Run transformations)
4. `uv run dbt test` (Test pipeline)
5. `uv run dbt docs generate` (Generate doc)
6. `uv run dbt docs serve` (Launch doc)


## 4.3. ⚙️ Interact with database

Once the database is created:
- Open the local db: `uv run duckcli ./nba_dwh.duckdb`
- Request data:

```sql
-- Career statistics of Rajon Rondo
select p.player_name, s.years, ps.nb_games, ps.avg_points, ps.avg_assists
from player_season ps
inner join player p on p.id = ps.player_id
inner join season s on s.id = ps.season_id
where p.player_name like 'Rajon Rondo'
order by s.years
```

# 5. 🔗 Internal Architecture

- Folder `/scraping`: Contains scripts to generate the raw data
- Folder `/transform`: Contains dbt project to generate the database


# 6. 🏆 Code Quality and Formatting

- The python files are linted and formatted using ruff, see configuration in `pyproject.toml`
- The dbt sql models files are formatted using sqlfmt
- Pre-commit configuration is available to ensure trigger quality checks (e.g. linter)
- Commit messages follow the conventional commit convention


# 7. 📚 Complementary documentation

- [DBT](https://docs.getdbt.com/docs/collaborate/documentation)
- [DuckDB](https://duckdb.org/docs/)
- [DBT-DuckDB adapter](https://github.com/duckdb/dbt-duckdb)
- See analysis based on this data, and leveraging bayesian statistics [here](https://pdgarden.github.io/nba-stats-eda/eda_nba_players_accuracy_evolution.html)