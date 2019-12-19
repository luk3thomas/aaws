#!/bin/bash

function aaws()
{
  export AAWS_AUTOCOMPLETE="$(grep '^\[' ~/.aws/credentials | sed -r 's/\[|\]//g')"

  complete -W "$AAWS_AUTOCOMPLETE" aaws

  if [ "-h " == "$@ " ]; then
    echo "usages: aaws [options] [<account>]"
    echo ""
    echo "  aaws       - Clear the current account"
    echo "  aaws -h    - Display help text"
    echo "  aaws prod  - Set your AWS_PROFILE to prod"
    return 0
  fi

  if [ "-q " == "$@ " ]; then
    return 0
  fi

  # Remove the account from our PS1
  PS1="$(echo "$PS1" | sed -r 's/\\e\[30;1m\[[^\]+]\\e\[0m 🔐 //')"

  if [ -z "$@" ]; then
    unset AWS_PROFILE
    return 0
  fi

  for e in ${AAWS_AUTOCOMPLETE[@]}; do
    if [ "$@" == "$e" ]; then
      export AWS_PROFILE=$@
      PS1="\e[30;1m[$@]\e[0m 🔐 $PS1"
      return 0
    fi
  done

  echo $@ "does not exist"
  return 1
}

function assh()
{
  if [ -z "$AWS_PROFILE" ]; then
    echo "No AWS_PROFILE set"
    return 0
  fi

  _asshu=""
  _assh123=()
  if [[ "$@" == *"@"* ]]; then
    _asshu="${@%@*}"
  fi

  while read -r l; do
    _assh123+=("$l")
  done <<< "$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].{Name:Tags[?Key==`Name`]|[0].Value,Ip:PrivateIpAddress}' --output text --filter "Name=tag:Name,Values=*${@#*@}*")"

  COLUMNS=12
  select opt in "${_assh123[@]}"; do
    case $opt in
      *)
        unset COLUMNS
        if [[ "$@" == *"@"* ]]; then
          ssh "$_asshu"@"$(echo $opt | cut -d ' ' -f1)"
        else
          ssh "$(echo $opt | cut -d ' ' -f1)"
        fi
        break
        ;;
    esac
  done
}

# Set the autocomplete vars
aaws -q

complete -W "$AAWS_AUTOCOMPLETE" aaws
