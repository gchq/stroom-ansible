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

main() {
  setup_echo_colours

  if [ ${#} -lt 1 ]; then
    echo -e "${RED}Error${NC}: Invalid arguments${NC}"
    echo -e "Usage: $0 inventory_file [ansible_arg...]"
    exit 1
  fi

  local inventory_file="$1"; shift

  if [ ! -f "inventory_file" ]; then
    echo -e "${RED}Error${NC}: File ${inventory_file} does not exist${NC}"
    exit 1
  fi

  # shellcheck disable=SC2034
  ANSIBLE_CONFIG=ansible_config.cfg \
    ansible-playbook \
    -i "${inventory_file}" \
    "$@" \
    ../../../stroom/test_dump_db_migration.yml
}

main "$@"
