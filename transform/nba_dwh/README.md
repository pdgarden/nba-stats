### NBA datawarehouse

Create a local datawarehouse for NBA data, using dbt and a bunch of raw data.

Try running the following commands:
- `dbt seed`
- `dbt run`
- `dbt test`
- `dbt docs generate`
- `dbt docs serve`
- Then run open the local db: `duckcli nba_dwh.duckdb`
- Request data: `select * from team_season order by nb_game_win`

> *TODO: add context, structure and approach*
