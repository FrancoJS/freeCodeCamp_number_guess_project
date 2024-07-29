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
  GUESS_NUMBER $1 
  
}

GUESS_NUMBER(){
  echo $1
  read USER_NUMBER
  if [[ ! $USER_NUMBER =~ ^[0-9]+$ ]]
  then
    echo "That is not a integer, guess again:"
    GUESS_NUMBER $1
  fi
  NUMBER_GUESSES=0
  while [ $USER_NUMBER -ne $1 ]
  do
    if [[ $USER_NUMBER > $1 ]]
    then
      echo "It's lower than that, guess again:"
      NUMBER_GUESSES+=1
      read USER_NUMBER
    fi
    if [[ $USER_NUMBER < $1 ]]
    then
      echo "It's higher than that, guess again:"
      NUMBER_GUESSES+=1
      read USER_NUMBER
    fi
    if [[ $USER_NUMBER == $1 ]]
    then
      echo "You guessed it in $NUMBER_GUESSES tries. The secret number was $1. Nice job!"
    fi
  done
}

MAIN $NUMBER