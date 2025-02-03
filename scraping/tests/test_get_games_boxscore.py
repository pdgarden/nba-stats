from pathlib import Path

import pandas as pd

from scraping.get_games_boxscore import GameBoxscores, clean_game_boxscores

TEST_DATA_FOLDER = Path(__file__).parent / "data"


def test_clean_game_boxscores() -> None:
    """Test the clean_game_boxscores function."""

    game_boxscores = GameBoxscores(
        game_id="20221018_Boston Celtics_Philadelphia 76ers",
        home_team="Boston Celtics",
        away_team="Philadelphia 76ers",
        home_team_boxscore=pd.read_parquet(TEST_DATA_FOLDER / "input" / "home_team_boxscore.parquet"),
        away_team_boxscore=pd.read_parquet(TEST_DATA_FOLDER / "input" / "away_team_boxscore.parquet"),
    )

    computed_df = clean_game_boxscores(game_boxscores)
    expected_df = pd.read_parquet(TEST_DATA_FOLDER / "output" / "clean_game_boxscore.parquet")

    pd.testing.assert_frame_equal(expected_df, computed_df)
