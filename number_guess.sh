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
  else
    IFS='|' read -r GAMES_PLAYED BEST_GAME < <($PSQL "select games_played, best_game from users where user_id = $USER_ID")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi

  echo "Guess the secret number between 1 and 1000:"
  GUESS_NUMBER $1 $USER_ID
  UPDATE_GAMES_PLAYED=$($PSQL "update users set games_played = games_played + 1 where user_id = $USER_ID")
  
}

GUESS_NUMBER(){
  echo $1
  read USER_NUMBER
  if [[ $USER_NUMBER =~ ^[0-9]+$ ]]
  then
    NUMBER_GUESSES=1
    if [[ $USER_NUMBER == $1 ]]
    then
    echo "You guessed it in $NUMBER_GUESSES tries. The secret number was $1. Nice job!"
    BEST_GAME=$($PSQL "select best_game from users where user_id = $2")
      if [[ -z $BEST_GAME || $NUMBER_GUESSES -lt $BEST_GAME ]]
      then
        UPDATE_BEST_GAME=$($PSQL "update users set best_game = $NUMBER_GUESSES where user_id = $2")
      fi
    else
    while [ $USER_NUMBER -ne $1 ]
    do
      if [[ $USER_NUMBER -gt $1 ]]
      then
        echo "It's lower than that, guess again:"
        read USER_NUMBER
        NUMBER_GUESSES=$((NUMBER_GUESSES + 1))
      fi
      if [[ $USER_NUMBER -lt $1 ]]
      then
        echo "It's higher than that, guess again:"
        read USER_NUMBER
        NUMBER_GUESSES=$((NUMBER_GUESSES + 1))
      fi
      if [[ $USER_NUMBER == $1 ]]
      then
        echo "You guessed it in $NUMBER_GUESSES tries. The secret number was $1. Nice job!"
        BEST_GAME=$($PSQL "select best_game from users where user_id = $2")
        if [[ -z $BEST_GAME || $NUMBER_GUESSES -lt $BEST_GAME ]]
        then
          UPDATE_BEST_GAME=$($PSQL "update users set best_game = $NUMBER_GUESSES where user_id = $2")
        fi
      fi
  done
  fi
  else
    echo "That is not a integer, guess again:"
    GUESS_NUMBER $1
  fi
}

MAIN $NUMBER