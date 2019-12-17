#!/bin/bash

# shellcheck disable=SC2034
ANSIBLE_CONFIG=vagrant_ansible_config.cfg \
  ansible-playbook \
  -i vagrant_inventory.yml \
  "$@" \
  ../../../stroom/install_remote_proxy.yml
