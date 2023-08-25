#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

  echo Enter your username:
  read USERNAME

  # create variable with username to check if username exists
  CHECK_USERNAME=$($PSQL "SELECT username FROM game_info WHERE username='$USERNAME'")

  if [[ -z $CHECK_USERNAME ]] # if username doesn't exist print one thing
  then
    ADD_USERNAME=$($PSQL "INSERT INTO game_info(username) values('$USERNAME')")
    echo Welcome, $USERNAME! It looks like this is your first time here.
  else # if username exists print something else
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM game_info WHERE username='$USERNAME'")
    BEST_GAME=$($PSQL "SELECT best_game FROM game_info WHERE username='$USERNAME'")
    echo Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
  fi

GAME () {

  # randomly generate number and read to a variable, also create guess variable
  SECRET_NUMBER=$(( ( RANDOM % 1000 )  + 1 ))
  NUM_TRIES=0
  GAME_COMPLETE=0

  # ask them to guess secret number
  echo Guess the secret number between 1 and 1000:

  while [[ $GAME_COMPLETE = 0 ]]
  do
    read USER_GUESS
    if [[ ! $USER_GUESS =~ ^[0-9]+$ ]] # if guess is not a number
    then echo That is not an integer, guess again:
    else # if guess is a number
      if [[ $USER_GUESS < $SECRET_NUMBER ]]  # if too high
      then 
        NUM_TRIES=$(($NUM_TRIES + 1))
        echo "It's higher than that, guess again: $SECRET_NUMBER"
      elif [[ $USER_GUESS > $SECRET_NUMBER ]] # if too low
      then
        NUM_TRIES=$(($NUM_TRIES + 1))
        echo "It's lower than that, guess again: $SECRET_NUMBER"
      else  # if correct
        NUM_TRIES=$(($NUM_TRIES + 1)) 
        GAME_COMPLETE=$(($GAME_COMPLETE + 1))
        echo "You guessed it in $NUM_TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"

        # insert into database
        OLD_GAMES_PLAYED=$($PSQL "SELECT games_played FROM game_info WHERE username='$USERNAME'")
        NEW_GAMES_PLAYED=$(($OLD_GAMES_PLAYED+1))
        INSERT_GAMES_PLAYED=$($PSQL "UPDATE game_info SET games_played=$NEW_GAMES_PLAYED WHERE username='$USERNAME'")

        OLD_BEST_GAME=$($PSQL "SELECT best_game FROM game_info WHERE username='$USERNAME'")
        if [[ ! -z $OLD_BEST_GAME ]] # if there is a prior best game
        then
          if [[ $OLD_BEST_GAME > $NUM_TRIES ]] # if there is a new best game
          then
            NEW_BEST_GAME=$($PSQL "UPDATE game_info SET best_game=$NUM_TRIES WHERE username='$USERNAME'")
          fi
        else # if no prior best game, add it in
          NEW_BEST_GAME=$($PSQL "UPDATE game_info SET best_game=$NUM_TRIES WHERE username='$USERNAME'")
        fi
      fi
    fi
  done
 
}

GAME