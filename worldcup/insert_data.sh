#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE teams, games;")

tail -n +2 games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS; do

  #insert teams
  for TEAM in "$WINNER" "$OPPONENT"; do

    #look in teams to see if it is already there
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$TEAM'")

    #insert if not there
    if [[ -z $TEAM_ID ]]
    then 
      INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$TEAM')")

      #make readable terminal output
      if [[ $INSERT_TEAM == "INSERT 0 1" ]] 
        then
          echo Inserted into teams, $TEAM
      fi
    fi
  done

  #insert games
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

  INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) 
              VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")

  #make readable terminal output
  if [[ $INSERT_GAME == "INSERT 0 1" ]] 
    then
      echo Inserted into games, $YEAR, $ROUND, $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS
  fi

done
