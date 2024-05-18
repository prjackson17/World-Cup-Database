#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
GAMES_CSV="games.csv"

# Truncate tables
echo $($PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY;")

# Reset the sequence explicitly (if needed)
# Reset teams table primary key sequence
echo $($PSQL "ALTER SEQUENCE teams_team_id_seq RESTART WITH 1;")
# Reset games table primary key sequence
echo $($PSQL "ALTER SEQUENCE games_game_id_seq RESTART WITH 1;")

# Read CSV line by line
while IFS=',' read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS;
do 
  # Skip header line
  if [[ $YEAR == year ]]
  then
    continue
  fi

  # Check if the winner team exists in the teams table
  WINNER_EXISTS=$($PSQL "SELECT count(*) FROM teams WHERE name='$WINNER';")
  if [[ $WINNER_EXISTS -eq 0 ]]
  then
    # Add winner team to teams table
    echo $($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")
  fi

  # Check if the opponent team exists in the teams table
  OPPONENT_EXISTS=$($PSQL "SELECT count(*) FROM teams WHERE name='$OPPONENT';")
  if [[ $OPPONENT_EXISTS -eq 0 ]]
  then
    # Add opponent team to teams table
    echo $($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")
  fi

  # Get the team IDs
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")

  # Add data to games
  echo $($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")

done < "$GAMES_CSV"
