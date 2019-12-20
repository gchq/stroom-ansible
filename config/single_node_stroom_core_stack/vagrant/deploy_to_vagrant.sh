#!/bin/bash

# shellcheck disable=SC2034
ANSIBLE_CONFIG=../example_inventory/ansible_config.cfg \
  ansible-playbook \
    -i ../example_inventory/vagrant_inventory.yml \
    "$@" \
    ../../../stroom/install_stack.yml
