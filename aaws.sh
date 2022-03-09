#!/bin/bash

function _aaws_PS1()
{
  if [ -z "$AWS_PROFILE" ]; then
    return 0
  fi

  echo $AAWS_AUTOCOMPLETE | while read e; do
    if [[ "$AWS_PROFILE" == "$e" ]]; then
      printf "\e[30;1m[$AWS_PROFILE]\e[0m 🔐 "
      return 0
    fi
  done
}

PS1="\$(_aaws_PS1)$PS1"

function aaws()
{
  export AAWS_AUTOCOMPLETE="$(grep '^\[' ~/.aws/credentials ~/.aws/config | cut -d : -f2 | sed -r -e 's/^\[profile /[/g' -e 's/\[|\]//g' | uniq)"

  complete -W "$AAWS_AUTOCOMPLETE" aaws

  if [[ "-h " == "$@ " ]] || [[ "--help " == "$@ " ]]
  then
    echo "usages: aaws [options] [profile]"
    echo ""
    echo "  aaws       - Clear the current profile"
    echo "  aaws -h    - Display help text"
    echo "  aaws -l    - Lists the available profiles"
    echo "  aaws prod  - Set your AWS_PROFILE to prod"
    return 0
  fi

  if [[ "-q " == "$@ " ]]; then
    return 0
  fi

  if [ -z "$@" ]; then
    unset AWS_PROFILE
    return 0
  fi

  if [[ "-l" == "$@" ]]; then
    echo $AAWS_AUTOCOMPLETE | while read e; do
      echo " $e"
    done
    return 0
  fi

  echo $AAWS_AUTOCOMPLETE | while read e; do
    if [[ "$@" == "$e" ]]; then
      export AWS_PROFILE=$@
      return 0
    fi
  done

  echo $@ "profile does not exist"
  return 1
}

# Set the autocomplete vars
aaws -q

complete -W "$AAWS_AUTOCOMPLETE" aaws
