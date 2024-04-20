<img src="https://img.shields.io/badge/python-3.11-blue" alt="Supported Python version">

# NBA stats

Data project using nba stats EDA. Will contain several parts:
- Scrapping: To get raw data
- Data engineering: To manipulate the data (using dbt & duckdb)
- Data analysis: To exploit the data

Datawarehouse documentation: [link](https://pdgarden.github.io/nba-stats/)

# Getting started

- `python3.11 -m venv venv`
- `source venv/bin/activate`
- `pip install -r requirements.txt`
- `pip install -r requirements-dev.txt`
- `pre-commit install -t commit-msg -t pre-commit`


# Run

## Scrapping scripts

- `cd ./scrapping`
- Generate `game_schedule.csv` : `python get_games_schedule.py`
- Generate `game_boxscore.csv` : `python get_games_boxscore.py`

> The generated data is then transfered to the sources of the dbt project: `cp ./scrapping/data/*.parquet ./transform/nba_dwh/local_source/`
`

## Modeling - DBT

- `cd ./transform/nba_dwh`
- Run transformations: `dbt run`
- Generate doc: `dbt docs generate`
- Launch doc `dbt docs serve`

Then to interact with the output data:
- Open the local db: `duckcli nba_dwh.duckdb`
- Request data: `select * from team_season order by nb_game_win`
