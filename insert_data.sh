#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
TRUNCATE_TABLES=$($PSQL "TRUNCATE games,teams")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $ROUND != "round" ]]
  then
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    if [ -z $WINNER_ID ]
    then
      TEAM_CREATION_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
      if [[ $TEAM_CREATION_RESULT == "INSERT 0 1" ]]
      then
        echo "Team $WINNER was created with id $WINNER_ID"
      fi
    fi
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    if [ -z $OPPONENT_ID ]
    then
      TEAM_CREATION_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
      if [[ $TEAM_CREATION_RESULT == "INSERT 0 1" ]]
      then
        echo "Team $OPPONENT was created with id $OPPONENT_ID"
      fi
    fi
    GAME_CREATION_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $GAME_CREATION_RESULT == "INSERT 0 1" ]]
      then
        echo "GAME $WINNER vs. $OPPONENT from $ROUND was created with $WINNER_GOALS-$OPPONENT_GOALS result"
    fi
  fi
done
