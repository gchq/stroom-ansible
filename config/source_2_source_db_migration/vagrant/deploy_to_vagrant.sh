#!/bin/bash

# shellcheck disable=SC2034
ANSIBLE_CONFIG=../example_inventory/ansible_config.cfg \
  ansible-playbook \
    -i ../example_inventory/vagrant_inventory.yml \
    "$@" \
    ../../../stroom/test_source_2_source_db_migration.yml
