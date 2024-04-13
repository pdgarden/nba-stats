"""
Get every games scheduled on a given season.
"""

# ------------------------------------------------------------------------------------------------ #
# Imports

import datetime
import json
import time
from pathlib import Path
from urllib.request import urlopen

import pandas as pd
from bs4 import BeautifulSoup
from loguru import logger
from pydantic import BaseModel, computed_field
from tqdm import tqdm

# ------------------------------------------------------------------------------------------------ #
# Constants

MAX_NB_REQUESTS_PER_MINUTE = 20
SECONDS_BETWEEN_REQUESTS = 60 / (MAX_NB_REQUESTS_PER_MINUTE - 1)

MONTHS = ["october", "november", "december", "january", "february", "march", "april", "may", "june"]
YEAR = 2023

DATA_FOLDER = Path("data")

# ------------------------------------------------------------------------------------------------ #
# Models


class Game(BaseModel):
    """Representation of a game info from basket ball reference"""

    basketball_reference_url: str
    home_team: str
    away_team: str
    date: datetime.date
    season_year: int

    @computed_field
    def game_id(self) -> str:
        return f"{self.date.strftime('%Y%m%d')}_{self.home_team}_{self.away_team}"


# ------------------------------------------------------------------------------------------------ #
# Functions


def extract_month_schedule(year: int, month: str) -> list[Game]:
    """Retrieve games info for a  given year and month.

    Args:
        year (int): Season start year
        month (str): month in lowercase letter, eg. january, december

    Returns:
        list[Game]: list of game schedule for the given month
    """

    # Get basket ball reference url
    URL_SCHEDULE = f"https://www.basketball-reference.com/leagues/NBA_{year}_games-{month}.html#schedule"

    # Query url
    html = urlopen(URL_SCHEDULE)  # noqa: S310

    # Get url content
    soup = BeautifulSoup(html, features="lxml")
    script_tag = soup.find("script", {"type": "application/ld+json"})
    script_content = script_tag.string.strip()

    # Convert the content to a JSON object
    games_json = json.loads(script_content)

    # Extract games URL
    games = []
    for game in games_json:
        games.append(
            Game(
                basketball_reference_url=game["url"],
                home_team=game["competitor"][1]["name"],
                away_team=game["competitor"][0]["name"],
                date=datetime.datetime.strptime(game["startDate"], "%a, %b %d, %Y").date(),
                season_year=year,
            )
        )

    return games


def extract_every_month_schedule(year: int) -> list[Game]:
    """Loop over every month do retrieve every games schedule.

    Args:
        year (int): Season start year

    Returns:
        list[Game]: list of game schedule for the given year
    """

    games_schedule = []
    for month in tqdm(MONTHS):
        time.sleep(SECONDS_BETWEEN_REQUESTS)
        games_schedule += extract_month_schedule(year=year, month=month)

    return games_schedule


def load_games_schedule(games_schedule: list[Game], year: int) -> None:
    """Load list of game schedule as csv.

    Args:
        games_schedule (list[Game]): list of game schedule
        year (int): Season start year
    """

    df_games_schedule = pd.DataFrame([res.model_dump() for res in games_schedule])

    games_schedule_filename = f"{year}_game_schedule.csv"
    games_schedule_path = DATA_FOLDER / games_schedule_filename

    logger.info(f"Load data at {games_schedule_path}")
    df_games_schedule.to_csv(games_schedule_path, index=False)


# ------------------------------------------------------------------------------------------------ #
# Main

if __name__ == "__main__":
    logger.info("Start scrapping")
    games_schedule = extract_every_month_schedule(year=YEAR)
    load_games_schedule(games_schedule=games_schedule, year=YEAR)
    logger.info("End")
