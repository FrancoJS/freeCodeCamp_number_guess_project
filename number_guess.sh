#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER=$((( RANDOM % 1000 ) + 1 ))

MAIN(){
  echo "Enter your username:"
  read USERNAME
  USER_ID=$($PSQL "select user_id from users where username = '$USERNAME'")
  if [[ -z $USER_ID  ]]
  then
    INSERT_USER_RESULT=$($PSQL "insert into users(username,games_played) values('$USERNAME', 0)")
    if [[ $INSERT_USER_RESULT == "INSERT 0 1" ]]
    then
      echo "Welcome, $USERNAME! It looks like this is your first time here."
    fi
  fi
}

MAIN