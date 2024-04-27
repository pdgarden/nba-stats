<img src="https://img.shields.io/badge/python-3.11-blue" alt="Supported Python version"> <img src="https://img.shields.io/static/v1?logo=dbt&label=dbt&message=1.7&color=blue"> <img src="https://img.shields.io/static/v1?logo=duckdb&label=duckdb&message=0.10&color=blue">

# NBA stats

- [1. 💬 Project description](#1--project-description)
- [2. 📟 Prerequisites](#2--prerequisites)
- [3. 🔌 Quickstart](#3--quickstart)
- [4. 🚀 Run](#4--run)
  - [4.1. Scrapping scripts](#41-scrapping-scripts)
  - [4.2. Create database](#42-create-database)
  - [4.3. Interact with database](#43-interact-with-database)
- [5. 🔗 Internal Architecture](#5--internal-architecture)
- [6. 🏆 Code Quality and Formatting](#6--code-quality-and-formatting)
- [7. 📚 Complementary documentation](#7--complementary-documentation)


# 1. 💬 Project description

This project aims to build a local database for retrieving NBA data through SQL queries. It is comprised of two main several parts:
- **Scrapping**: To get raw data
- **Data engineering:** To manipulate the data using dbt & duckdb

Datawarehouse documentation: [link](https://pdgarden.github.io/nba-stats/)


# 2. 📟 Prerequisites

The project is developped and tested under python 3.11. No specific environment variable is necessary.


# 3. 🔌 Quickstart

To setup and use the project locally, execute the following steps:

1. `python3.11 -m venv venv` (Create virtual environment)
2. `source venv/bin/activate` (Activate virtual environment)
3. `pip install -r requirements.txt` (Install main requirements)
4. `pip install -r requirements-dev.txt` (Install dev related requirements)
5. `pre-commit install -t commit-msg -t pre-commit` (Setup pre-commit)



# 4. 🚀 Run

## 4.1. Scrapping scripts
<details>
  <summary>This is not necessary to execute it again as the data is already extracted</summary>

- `cd ./scrapping`
- Generate `game_schedule.csv` : `python get_games_schedule.py`
- Generate `game_boxscore.csv` : `python get_games_boxscore.py`

> The generated data is then transfered to the sources of the dbt project: `cp ./scrapping/data/*.parquet ./transform/nba_dwh/local_source/`
`

</details>

## 4.2. Create database

The following section describe the steps to create the local duckdb database, leveraging dbt:

1. `cd ./transform/nba_dwh`
2. `dbt run` (Run transformations)
3. `dbt docs generate` (Generate doc)
4. `dbt docs serve` (Launch doc)


## 4.3. Interact with database

Once the database is created:
- Open the local db: `duckcli ./nba_dwh.duckdb`
- Request data: `select * from team_season order by nb_game_win`


# 5. 🔗 Internal Architecture

- Folder `/scrapping`: Contains scripts to generate the raw data
- Folder `/transform`: Contains dbt project to generate the database


# 6. 🏆 Code Quality and Formatting

- The python files are linted and formated using ruff, see configuration in `pyproject.toml`
- The dbt sql models files are formated using sqlfmt
- Pre-commit configuration is available to ensure trigger quality checks (e.g. linter)
- Commit messages follow the conventional commit convention


# 7. 📚 Complementary documentation

- [DBT](https://docs.getdbt.com/docs/collaborate/documentation)
- [DuckDB](https://duckdb.org/docs/)
- [DBT-DuckDB adaptater](https://github.com/duckdb/dbt-duckdb)