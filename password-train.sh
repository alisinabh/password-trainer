#!/bin/bash -e

attempts_correct=0
attempts=0

echo "Hi. I'm Password trainer. I will help you to remember your password."

init() {
  echo -n "Please enter the correct password:"
  read -s correct_password
  echo

  echo -n "Please repeat the correct password:"
  read -s repeat
  echo

  if [ "$correct_password" = "$repeat" ]; then
    echo "Congrats"

    if [[ $correct_password =~ [A-Z] ]] && [[ $correct_password =~ [a-z] ]] && [[ $correct_password =~ [0-9] ]] && [[ ${#correct_password} -ge 8 ]]; then
      echo_green "Your password looks good, Make sure it does not contain any common words or phrases"
      echo
    else
      echo_red "Your password looks weak! We strongly recommend you to choose a password containing uppercase and lowercase letters including numbers and special chars e.g. (!, @, #...)"
    fi

    echo -n "How many times do you want to take the test? [10]"
    read train_count
  else
    echo "Wrong password entered!"
    init
  fi
}

train_once() {
  echo -n "Password: "
  train_password=""
  last_char="NA"
  hint_indx=0
  while [ "$last_char" != "" ]
  do
    read -n1 -s last_char
    case $last_char in
      $'\x08')
        # Hint on ctrl+h
        clear
        echo -n "Password: "
        chardiff $correct_password $train_password
        ;;

      $'\177')
        if [ "$train_password" != "" ]; then
          cnt=$((${#train_password} - 1))
          train_password="${train_password:0:cnt}"
        fi
        ;;

      *)
        train_password="$train_password$last_char"
        ;;
    esac
  done
  echo

  if [ "$train_password" = "$correct_password" ]; then
    clear
    echo_green "CORRECT! ($((attempts+1))/$train_count)"
    attempts_correct=$((attempts_correct+1))
  else
    clear
    echo_red "WRONG :("
    chardiff $correct_password $train_password
    echo
  fi

  attempts=$((attempts+1))
}

echo_red() {
  echo -e "\033[31m$1\033[0m"
}

echo_green() {
  echo -e "\033[32m$1\033[0m"
}

chardiff() {
  for i in $(seq 0 ${#1})
  do
    expected_char=${1:$i:1}
    input_char=${2:$i:1}
    if [ "$expected_char" = "$input_char" ]; then
      echo -en "\033[32m$input_char\033[0m"
    elif [ "$input_char" = "" ]; then
      echo -en "\033[33m${expected_char}\033[0m"
    else
      echo -en "\033[31m${input_char}\033[0m"
    fi
  done
}

# Initialize the password
init

# Start training
clear
echo "Ctrl+h for hinting your typed password"

train_count=${train_count:-10}

start_at=$(date +%s)
for i in $(seq 1 $train_count)
do
  train_once
done
end_at=$(date +%s)
total_seconds=$((end_at-start_at))

# Print summary result
clear
echo

success_rate=$((attempts_correct*100/attempts))

echo -n "Your score "

if [[ $success_rate -ge 80 ]]; then
  echo -ne "\033[32m"
  msg="Yeayyy, Looks like you know your password."
elif [[ $success_rate -ge 50 ]]; then
  echo -ne "\033[33m"
  msg="Keep going, You can do it!"
else
  msg="Practice makes perfect."
  echo -ne "\033[31m"
fi

echo -e "($success_rate%) $attempts_correct\033[0m/$attempts"
echo $msg

echo

average_password_time=$((total_seconds/attempts))
echo -n "And it took you "
if [[ $average_password_time -ge 6 ]]; then
  echo -ne "\033[33m"
else
  echo -ne "\033[32m"
fi
echo -e "$average_password_time\033[0m seconds for each password on average"
