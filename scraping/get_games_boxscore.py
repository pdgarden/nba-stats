"""
Get every games boxscore on a given season.
"""

# ------------------------------------------------------------------------------------------------ #
# Imports

import time

import pandas as pd
from loguru import logger
from pydantic import BaseModel
from tqdm import tqdm

from scraping.get_games_schedule import DATA_FOLDER, SECONDS_BETWEEN_REQUESTS, YEAR, Game

# ------------------------------------------------------------------------------------------------ #
# Models


class GameBoxscores(BaseModel):
    """Games boxscore from away and home team."""

    game_id: str
    home_team: str
    away_team: str
    home_team_boxscore: pd.DataFrame
    away_team_boxscore: pd.DataFrame

    class Config:
        arbitrary_types_allowed = True


# ------------------------------------------------------------------------------------------------ #
# Functions


def extract_games_schedule(year: int) -> list[Game]:
    """Extract games from local parquet file.

    Args:
        year (int): Season start year

    Returns:
        list[Games]: list of game schedule for the given year
    """

    input_filepath = DATA_FOLDER / f"game_schedule_{year}.parquet"  # TODO mutualize
    df_games_schedule = pd.read_parquet(input_filepath)

    games = [
        Game(
            basketball_reference_url=row.basketball_reference_url,
            home_team=row.home_team,
            away_team=row.away_team,
            date=row.date,
            season_year=year,
        )
        for row in df_games_schedule.itertuples()
    ]
    return games


def extract_boxscore(game: Game) -> GameBoxscores:
    """Retrieve raw boxscore of both teams for a game

    Args:
        game (Game): game schedule

    Returns:
        GameBoxscores: Contain the raw home and away team boxscore
    """

    time.sleep(SECONDS_BETWEEN_REQUESTS)
    dfs = pd.read_html(game.basketball_reference_url, match="Basic Box Score Stats")

    home_team_df_position, away_team_df_position = int(len(dfs) / 2), 0

    return GameBoxscores(
        game_id=game.game_id,
        home_team=game.home_team,
        away_team=game.away_team,
        home_team_boxscore=dfs[home_team_df_position].copy(),
        away_team_boxscore=dfs[away_team_df_position].copy(),
    )


def clean_game_boxscores(game_boxscores: GameBoxscores) -> pd.DataFrame:
    """Retrieve a cleaned and transformed verison of the game boxscores

    Args:
        game_boxscores (GameBoxscores): Raw home and away team boxscore

    Returns:
        pd.DataFrame: Stack of both home and away team boxscore
    """

    df_boxscore_away = game_boxscores.away_team_boxscore.copy()
    df_boxscore_away.columns = [col[1] for col in df_boxscore_away.columns]

    df_boxscore_home = game_boxscores.home_team_boxscore.copy()
    df_boxscore_home.columns = [col[1] for col in df_boxscore_home.columns]

    df_boxscore_home["team"] = game_boxscores.home_team
    df_boxscore_away["team"] = game_boxscores.away_team

    df_boxscore = pd.concat([df_boxscore_home, df_boxscore_away])
    df_boxscore["game_id"] = game_boxscores.game_id

    return df_boxscore


def extract_every_boxscores(games: list[Game], save_checkpoints: bool = True) -> pd.DataFrame:
    """Loop over every games do retrieve every games boxscores.

    Args:
        games (list[Game]): list of game schedule
        save_checkpoints (bool, optional): Save intermediate boxscore in case an issue appears while
                                           handling loop. Defaults to True.


    Returns:
        pd.DataFrame: boxscores of every games stacked
    """

    boxscores = []
    for game in tqdm(games):
        raw_boxscore = extract_boxscore(game=game)
        clean_boxscore = clean_game_boxscores(game_boxscores=raw_boxscore)
        boxscores.append(clean_boxscore)

        if save_checkpoints:
            pd.concat(boxscores).to_parquet(DATA_FOLDER / "checkpoint_game_boxscore.parquet", index=False)

    return pd.concat(boxscores)


def load_games_boxscore(df_games_boxscore: pd.DataFrame, year: int) -> None:
    """Load list of game boxscore as parquet.

    Args:
        df_games_boxscore (list[Game]): list of game boxscore
        year (int): Season start year
    """

    games_boxscore_filename = f"game_boxscore_{year}.parquet"
    games_boxscore_path = DATA_FOLDER / games_boxscore_filename

    logger.info(f"Load data at {games_boxscore_path}")
    df_games_boxscore.to_parquet(games_boxscore_path, index=False)


# ------------------------------------------------------------------------------------------------ #
# Main
if __name__ == "__main__":
    logger.info("Start scraping")

    games = extract_games_schedule(year=YEAR)
    games_boxscore = extract_every_boxscores(games=games)
    load_games_boxscore(df_games_boxscore=games_boxscore, year=YEAR)

    logger.info("End")
