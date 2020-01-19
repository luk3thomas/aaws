#!/bin/bash

function _aaws_PS1()
{
  if [ -z "$AWS_PROFILE" ]; then
    return 0
  fi

  for e in ${AAWS_AUTOCOMPLETE[@]}; do
    if [[ "$AWS_PROFILE" == "$e" ]]; then
      printf "\e[30;1m[$AWS_PROFILE]\e[0m 🔐 "
      return 0
    fi
  done
}

PS1="\$(_aaws_PS1)$PS1"

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

  if [ -z "$@" ]; then
    unset AWS_PROFILE
    return 0
  fi

  for e in ${AAWS_AUTOCOMPLETE[@]}; do
    if [ "$@" == "$e" ]; then
      export AWS_PROFILE=$@
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
  done <<< "$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].{Name:Tags[?Key==`Name`]|[0].Value,Ip:PrivateIpAddress}' --output text --filter "Name=tag:Name,Values=*${@#*@}*" | sort -k 2 -t "\t")"

  COLUMNS=12
  select opt in "${_assh123[@]}"; do
    case $opt in
      *)
        if [[ "$opt" == "" ]]; then
          break
        fi

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
