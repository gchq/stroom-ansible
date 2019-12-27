# stroom-ansible

---
> WARNING: The majority of this document is out of date and needs updating. It
> has mostly been superseded by the content in the root readme.
---

## Prerequisites

1. Create four Centos 7 hosts
1. Create a user to run the install as, e.g. a human user account.
1. Grant the install user passwordless `sudo su -` rights.
1. Create an ssh key pair for the install user or add an existing public key to the authorized_keys file to allow passwordless ssh connections.

## AWS Provisioning steps

1. Create a key pair on aws, download the pem to `~/.ssh`
1. Create the security group
1. Create 4 instances using the stroom template

## Install Steps

1. Update `../config/ansible_inventory` with the host names of the new instances (in the appropriate roles)
1. Update `../config/user_settings.yml`
  1. Set `ansible_ssh_private_key_file` to the path of the above pem file
  1. Set `stroom_version` to the required stroom version
  1. Set `stack_version` to the required stack version, if different from the stroom version
1. Run `ansible-playbook -v ./yum_update.yml` to do a YUM update and reboot
1. Run `ansible-playbook -v ./setup_stroom_hosts.yml` to set up the hosts with docker, java and CLI tools
1. Run `ansible-playbook -v ./setup_mysql.yml` to set up the db host with mysql and prep the DBs
1. Run `ansible-playbook -v ./download_release.yml` to download the stroom and stack releases archives

1. MANDROLIC: Copy the exploded releases from downloads to ./stroon and ./stroom_core TODO need to automate

1. Run `ansible-playbook -v ./update_config.yml` to apply the hostnames/ports to the local config files
1. Run `ansible-playbook -v ./install_stack.yml` to install the stack on the service host
1. Run `ansible-playbook -v ./set_services.yml` to set the required docker servcies on the services node(s)
1. Run `ansible-playbook -v ./install_stroom.yml` to install stroom on the stroom hosts
1. Run `ansible-playbook -v ./send_config.yml` to send the updated config to the service and stroom hosts
1. On the services node run `cd ~/stroom_core/latest; ./start.sh` to start the services stack.
1. On each of the stroom nodes run `cd ~/stroom/latest; ./start.sh` to start stroom.
1. In a browser open `http://<services node fqdn>/stroom`

## Post Install Steps

1. Create an index volume on shared storage.
1. Create a stream store volumes on shared storage.
1. Set the cluster call urls for the nodes.


## TODO
  1. Give install user rights to sudo up to `stroomuser`.
  1. Change `stroom.serviceDiscovery.simpleLookup.basePath` to use localhost, or maybe it should go via api gateway
  1. Disable creation of default volumes as they do not work in multi node setup.
  1. Enable content pack import
  1. Create certs with fqdns in the SAN list
  1. Sort out proxy
  1. Update this doc
  1. Find a way to intermingle docker/non-docker stroom and mysql in the ansible playbooks/roles
  1. Add steps for opening ports in firewalld for stroom to function
  1. Change stroom* install steps to install to /opt
  1. Consider how to make the install run with no internet, i.e. get archives from a path on ansible master.


## Host Groups

These are the host groups that are used in the Ansible inventory.

* stroom_and_proxy_stack - Stroom, local proxy and log-sender running in a docker stack.
* stroom_core_stack - A single node stroom stack running all of the core application.
* stroom_services_stack - Nginx, auth* and log-sender running in a docker stack.
* stroom_dbs_stack - Mysql running in a docker.
* stroom_and_proxy - Stroom and local proxy running without docker.
* stroom_database - Mysql running outside of docker.
* stroom_remote_proxy_stack - Nginx and stroom-proxy in a docker stack.










This directory contains the ansible scripts necessary for setting up a multi-node Stroom v6.0.

## Assumptions and caveats

- You have a number of machines available. a minimum of 3.
- These machines don't have any firewalls running.
- You're using the following host groups/stacks: `stroom_and_proxy_stack`, `stroom_services_stack`, `stroom_dbs_stack`.

These will change as the ansible scripts evolve.

This has been tested on AWS. The AMI used is `ami-0ff760d16d9497663`, a Centos 7.0 image.

## Getting the Ansible scripts

```sh
git clone https://github.com/gchq/stroom-resources
```

The ansible scripts are in `stroom-resources/ansible`.


## Choosing the location of your configuration

Nothing changes in this repository when configuring and running an environment. The files that are generated and used to configure the environment should be stored elsewhere and source controlled as you wish. You need to symlink to wherever these files reside, or will reside after they've been generated automatically. Do this, replacing the path where obvious:

``` sh
# Or 'ln -sf ...' if you're so inclined
ln --symbolic --force /path/to/your/config config 
```
 
## Updating the inventory

The location of the Ansible inventory file is defined in `ansible.cfg`. If you're using aws you can use the aws playbooks (also in this repository) to create your hosts and generate this file, otherwise you'll need to write it yourself, put it somewhere sensible, and update `ansible.cfg` with that location.

## The Stroom configuration
The `releases` folder contains stack releases. The symlink `latest` should always point to the most recent one. That's the location used by the playbooks to find the config it needs to send to the hosts.


 - your stroom configuration files -- these are the files that configure the stroom services themselves, and they're copied onto the hosts when you run the `update_config` playbook. An example is in `examples/conf`.

You need a service name; an FQDN that the user will visit. This name is important and needs to be used in a few places within the configuration. For this name you could take the first host name in the `stroom_services_stack` host group.

You also need the host name of the database machine.

The following all need the database host name
 - `./conf/stroom_services/stroom_services.env` - update:
   - `STROOM_AUTH_DB_HOST`
 - `./conf/stroom_and_proxy/stroom_and_proxy.en`v - update:
   - `STROOM_DB_HOST`
   - `STROOM_STAT_SDB_HOST`

The following all need the service name:
 - `./conf/nginx/server.conf.template`
 - `./conf/stroom_services/stroom_services.env`, the following variables:
   - `HOST_IP`
 - `./conf/stroom_and_proxy/stroom_and_proxy.env`, the following variables:
   - `HOST_IP`

NGINX reverse-proxies everything, so we need to tell nginx where the hosts live. These are in the upstream files. You'll want to update these to match how you updated `hosts`. Stroom and Proxy will have more or less the same upstreams.
 - `./conf/nginx/upstreams.auth.conf.template`
 - `./conf/nginx/upstreams.stroom.conf.template`
 - `./conf/nginx/upstreams.proxy.conf.template`

You'll also need to update the two redirects in `./conf/nginx/locations.stroom.conf.template`.

## Setting up the hosts

```sh
ansible-playbook -i hosts setup_stroom_hosts.yml
```

## Installing the stacks

```sh
ansible-playbook -i hosts install_stack.yml
```

## Copying the config to the nodes

You have the stacks but you need to make sure the config you changed above is copied to the nodes. 
```sh
ansible-playbook -i hosts update_config.yml
```

## Controlling the stacks

A Stroom stack has several scripts to control it. 
 - To start and stop: start/stop/restart
 - To get information about the stack: health/info/show_config/logs/status
 - To clean up: remove

### Controlling the stack using tmux
Although tmux involves opening several ssh sessions to the boxes and is therefore terribly old-school, it is also much easier to work with than using ansible to control and monitor a stack. I.e. you can use ansible to set up your environments, install and update stroom and its config, but you might have more joy using tmux for control and monitoring.

You can create a tmuxinator layout from your ansible inventory by running:

``` 
./scripts/create_tmuxinator_layout.sh stroom_test
```
In the above `stroom_test` is the name of the layout. Then you can use that name to start a tmux session, automatically connecting to your hosts:

``` sh
tmuxinator stroom_test
```

### Controlling the stack using ansible
NB/TODO: logs doesn't work very well because it tails and doesn't complete.

If you want to execute these on all stacks do the following:
```sh
ansible-playbook -i hosts run_script_on_all.yml
```

You will then be prompted for the script you want to run. There are currently no checks to make sure you've entered a valid script, so get it right. 

You can also run these on a single host group by running a similarly named script:
```sh
ansible-playbook -i hosts run_script.yml
```

This will prompt you for the host group.

You can bypass the prompt for either of these as follows:
```sh
ansible-playbook -i hosts run_script_on_all.yml --extra-vars "op=restart"
ansible-playbook -i hosts run_script_on_all.yml --extra-vars "op=restart stack_type=stroom_services_stack"
```

## Removing a stack
You can do the following to remove all the containers:
```sh
ansible-playbook -i hosts run_script_on_all.yml --extra-vars "op=remove"
```

You can then delete all the files that were moved there:
```sh
ansible-playbook -i hosts delete.yml
```
