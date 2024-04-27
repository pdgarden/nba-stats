### NBA datawarehouse

Create a local datawarehouse for NBA data, using dbt and a bunch of raw data. The raw data is located under the `local_source` folder. When dbt runs, it creates the `nba_dwh.duckdb` db file.

Try running the following commands from the `nba_dwh` directory:
- `dbt deps`
- `dbt run`
- `dbt test`
- `dbt docs generate`
- (To see the generated doc) `dbt docs serve`
- Then run open the local db: `duckcli nba_dwh.duckdb`
- Request data: `select * from team_season order by nb_game_win limit 10;`
