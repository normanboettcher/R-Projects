library(DBI)
library(RSQLite)

setwd('/home/norman/Schreibtisch/R/')
con <- dbConnect(SQLite(), dbname="database.sqlite")
tables <- dbListTables(con)
tables

query = 'select * from Match'
matches <- dbSendQuery(con, query)
result_matches <- fetch(matches)
head(result_matches)
dbClearResult(result_matches)

count_matches <- fetch(dbSendQuery(con, 'select count(*) from Match'))
count_matches

count_players <- fetch(dbSendQuery(con, 'select count (*) from Player'))
count_players
dbClearResult(count_players)

teams <- fetch(dbSendQuery(con, 'select * from Team'))
head(teams)

leagues <- fetch(dbSendQuery(con, 'select * from League'))
leagues
dbClearResult(leagues)

germany_team_query <- paste(
'select team_long_name as team, team_api_id as id from Team', 
'left join Match on Team.team_api_id = Match.home_team_api_id',
'where Match.country_id = 7809 group by team_long_name'

teams_germany <- fetch(dbSendQuery(con, germany_team_query))
teams_germany

