#!/usr/bin/env bash

set -e

setup_echo_colours() {
  # Exit the script on any error
  set -e

  # shellcheck disable=SC2034
  if [ "${MONOCHROME}" = true ]; then
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    BLUE2=''
    DGREY=''
    NC='' # No Colour
  else 
    RED='\033[1;31m'
    GREEN='\033[1;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[1;34m'
    BLUE2='\033[1;34m'
    DGREY='\e[90m'
    NC='\033[0m' # No Colour
  fi
}

debug_value() {
  local name="$1"; shift
  local value="$1"; shift
  
  if [ "${IS_DEBUG}" = true ]; then
    echo -e "${DGREY}DEBUG ${name}: ${value}${NC}"
  fi
}

debug() {
  local str="$1"; shift
  
  if [ "${IS_DEBUG}" = true ]; then
    echo -e "${DGREY}DEBUG ${str}${NC}"
  fi
}

main() {
  IS_DEBUG=false
  setup_echo_colours

  if [ "$#" -ne 2 ]; then
    echo -e "${RED}Error${NC}: Invalid arguments"
    echo -e "Usage: $0 pattern command"
    echo -e "E.g.:  $0 '~(stroom_and_proxy|.*_stack)' 'echo hostname'"
    exit 1
  fi

  local pattern="$1"; shift
  local shell_cmd="$1"; shift

  echo -e "${GREEN}Running command ${BLUE}${shell_cmd}${GREEN} on hosts ${BLUE}${pattern}${NC}"

  # shellcheck disable=SC2034
  ANSIBLE_CONFIG=vagrant_ansible_config.cfg \
    ansible \
    "${pattern}"\
    -vv \
    -m shell \
    -a "${shell_cmd}" \
    --become \
    -i vagrant_inventory.yml
}

main "$@"
