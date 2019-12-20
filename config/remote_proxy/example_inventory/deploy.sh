#!/bin/bash

# shellcheck disable=SC2034
ANSIBLE_CONFIG=ansible_config.cfg \
  ansible-playbook \
  -i vagrant_inventory.yml \
  "$@" \
  ../../../stroom/install_stack.yml
