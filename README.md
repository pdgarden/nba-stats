<img src="https://img.shields.io/badge/python-3.11-blue" alt="Supported Python version">

# NBA stats

Data project using nba stats EDA. Will contain several parts:
- Scrapping: To get raw data
- Data engineering: To manipulate the data (using dbt & duckdb)
- Data analysis: To exploit the data



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
