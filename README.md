# stroom-ansible

A home for all stroom related Ansible playbooks, roles, etc. for deploying
stroom and other members of the stroom family.

> This repository is currently _work in progress_ so here be dragons!

The Ansible playbooks and associated configuration in this repository serve as
a set of reference/example deployments. Stroom can be deployed into
environments of many different shapes and sizes so there is no single install
guide. This repository can be forked and modified to produce your own
deployment.

The Ansible playbooks/roles were written for Centos 7 so deployment into a
different OS would require changes.

## Basic Structure

``` sh
.
├── aws - # Files for provisioning hosts on AWS (Incomplete)
├── config - # Example deployment configurations/inventories
│   ├── xxx_yyy # Root dir for the deployment type xxx_yyy, e.g. remote_proxy
│   │   ├── example_inventory # An example Ansible configuration/inventory
│   │   └── vagrant # Vagrantfile for provisioning example hosts
│   ├...
│
└── stroom # Ansible playbooks
    ├── roles # Ansible roles
    │   ├── build_stroom_source # Roles for running stroom java builds
    │   ├── non_docker_proxy # Stroom outside of docker
    │   ├── non_docker_stroom # Stroom-proxy outside of docker
    │   ├── setup # General host set up roles
    │   ├── stack # Roles for stroom docker stacks
    │   └── third_party # Any third party Ansible roles
    └── scripts # Any scripts used in the plays/roles
```

## Example Deployment Configurations

### Single Node Stroom Core Stack

`config/single_node_stroom_core_stack`

This is a deployment of the _stroom core stack_ on a single node. All services
run in Docker containers. This is suitable for small scale deployments or
testing.

### Multi Node Stroom Core Stack

> TODO

### Multi Node Mixed Cluster

`config/multi_node_mixed_cluster`

This is a four node cluster consisting of a single node running the _stroom
services_ docker stack, a single node running a MySql database and two stroom
nodes each running stroom and stroom-proxy-local outside of Docker.

### Remote Proxy

`config/remote_proxy`

This is a deployment of a _stroom proxy_ docker stack on a single node. It is
intended for deploying stroom-proxy instances that are more local to the
applications sending data to stroom.

By adding more hosts it could be used to deploy a farm of independent remote
proxies.

## How to Deploy a Configuration

The following steps show you how to deploy the Stroom Core Stack configuration
into Vagrant provisioned Centos 7 virtual machines running in VirtualBox.

Vagrant/VirtualBox are used as a means of providing hosts to deploy onto and
generating an Ansible inventory that describes those hosts. All of the Ansible
roles/playbooks can be used without Vagrant/VirtualBox provided that an
alternative Ansible inventory file is provided.

In each config directory an `example_inventory.yml` file is provided as an
example of how to structure an Ansible inventory for that shape of deployment.

### Prerequisites

VirtualBox - https://www.virtualbox.org/wiki/Downloads

Vagrant - https://www.vagrantup.com/docs/installation/

Ansible - https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html

### Steps

1. Start VirtualBox

1. Create the virtual machine(s) with Vagrant.  This will also generate the
   Ansible inventory for them.

  > NOTE: The VMs will be created with static IPs of 192.168.10[0-9].*

  ```bash
  cd stroom-ansible/config/multi_node_mixed_cluster/vagrant
  vagrant up
  ```

  When you run the `up` command it will display the hostnames, Ansible groups
  and IPs for each host.

1. Run the Ansible playbook to setup the host(s) and deploy stroom.

  ```bash
  cd stroom-ansible/config/multi_node_mixed_cluster/example_inventory
  ./run_playbook.sh
  ```

1. You can SSH onto Vagrant host using its hostname, e.g.

  ```bash
  cd stroom-ansible/config/multi_node_mixed_cluster/vagrant
  vagrant ssh stroom-and-proxy-host-1
  ```

1. To shutdown the Vagrant host(s) run

  ```bash
  cd stroom-ansible/config/multi_node_mixed_cluster/vagrant
  vagrant halt
  ```

### Running Ansible without Vagrant

If you have provided your own hosts then you can just run the Ansible playbook
against them.

1. Create an inventory file similar to `example_inventory.yml` that contains
   the details of your hosts.

1. Run the playbook from the directory containing the `example_inventory.yml`
   file as follows:

  ```bash
  ANSIBLE_CONFIG=ansible_config.cfg ansible-playbook -i other_inventory.yml ../../../stroom/install_mixed_cluster.yml
  ```
  Where `other_inventory.yml` is the new inventory file you created.

