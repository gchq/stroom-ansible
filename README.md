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
│   │   │   ├── files_and_templates
│   │   │   │   ├── stroom # Files/templates for the (non docker) stroom home dir
│   │   │   │   ├── stroom-proxy # Files/templates for the (non docker) stroom-proxy home dir
│   │   │   │   └── volumes # Files/templates for the stack volumes dir
│   │   │   └── group_vars
│   │   └── vagrant # Vagrantfile for provisioning example hosts
│   ├...
│
└── stroom # Ansible playbooks
    ├── roles # Ansible roles
    │   ├── build_stroom_source # Roles for running stroom java builds
    │   ├── non_docker_proxy # Stroom-proxy outside of docker
    │   ├── non_docker_stroom # Stroom outside of docker
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

### Dump to Source DB Migration

`config/dump_2_source_db_migration`

This configuration/playbook performs a test of a database migration from one
version to another. The test is performed using a set of database backups from
the source version which will be imported into empty databases for migration to
the destination version.  The destination version is build from source using a
git tag or commit hash.  The DB imports can either be taken from a production
system or exported from a test version of stroom running in the IDE.

If the test is successful, the application can be opened to verify the state of
the content/data/application.

### Source to Source DB Migration

`config/source_2_source_db_migration`

This configuration/playbook performs a test of a database migration from one
version to another. The test is performed using a build from the java source to
enable the use of the _SetupSampleData_ test content. No stream processing is
done on the SetupSampleData data/content.

If the test is successful, the application can be opened to verify the state of
the content/data/application.

### Dump to Stack DB Migration

`config/dump_2_stack_db_migration`

This configuration/playbook performs a test of a database migration from one
version to another. The test is performed using a set of database backups from
the source version which will be imported into empty databases for migration to
the destination version. The destination version is a released stack version.
This is intended to be used with a backup of a production system to test major
migrations.

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

Ansible - https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html

The following are only needed if you want to use Vagrant and VirtualBox to
create hosts to deploy to.

VirtualBox - https://www.virtualbox.org/wiki/Downloads

Vagrant - https://www.vagrantup.com/docs/installation/

### Steps

1. Start VirtualBox

1. Create the virtual machine(s) with Vagrant.  This will also generate the
   Ansible inventory for them.

  > NOTE: The VMs will be created with static IPs of 192.168.10[0-9].*

  ```bash
  cd config/multi_node_mixed_cluster/vagrant
  vagrant up
  ```

  When you run the `up` command it will display the hostnames, Ansible groups
  and IPs for each host.

1. Run the Ansible playbook to setup the host(s) and deploy stroom.

  ```bash
  ./deploy_to_vagrant.sh
  ```

1. You can SSH onto Vagrant host using its hostname, e.g.

  ```bash
  vagrant ssh stroom-and-proxy-host-1
  ```

1. To shutdown the Vagrant host(s) run

  ```bash
  vagrant halt
  ```

### Running Ansible Without Vagrant

If you have provided your own hosts then you can just run the Ansible playbook
against them.

1. Create an inventory file similar to `example_inventory.yml` that contains
   the details of your hosts.

1. Run the playbook from the directory containing the `example_inventory.yml`
   file as follows:

  ```bash
  cd config/multi_node_mixed_cluster/example_inventory
  ./deploy.sh other_inventory.yml
  ```
  Where `other_inventory.yml` is the new inventory file you created.

## Configuring a Deployment

The following is rough description of the various parts of the configuration
directory and how they work to produce a particular shape of deployment for a
specific environment.

### Ansible Inventory Hosts

A deployment requires some form of inventory to define the hosts that make up
the deployment and which hosts belong to which host groups. This can either be
a static YAML/INI file, a file that is generated by, for example, Vagrant, or a
dynamic inventory produced by, for example, by using the AWS inventory plugin
to query AWS for pre-created EC2 hosts.

The host groups that are used by the Ansible roles/plays are as follows.

* With Docker
  * `stroom_and_proxy_stack` - Stroom, local proxy and log-sender running in a docker stack.
  * `stroom_core_stack` - A single node stroom stack running all of the core application.
  * `stroom_services_stack` - Nginx, stroom-auth* and log-sender running in a docker stack.
  * `stroom_dbs_stack` - Mysql running in a docker.
  * `stroom_remote_proxy_stack` - Nginx and stroom-proxy in a docker stack.
* Without Docker
  * `stroom` - Stroom running without docker.
  * `stroom_ui` - Stroom running without docker.
  * `stroom_with_proxy` - Stroom and local legacy proxy running without docker.
  * `stroom_and_proxy` - Stroom and local proxy running without docker.
  * `stroom_proxy` - Stroom Proxy running without docker.
  * `stroom_database` - Mysql running without docker for stroom & auth databases.
  * `stroom_stats_database` - Mysql running without docker for stats database.

### Group Vars

The bulk of the configuration is contained in the `group_vars/all` file. This
contains variables that are applicable to all hosts in the deployment. This
file is used to define things like the version of stroom being deployed, the
type of stack being deployed, the directory to install to, etc.

Variable that are only applicable to one host group can be defined in the file
for that group, e.g. `group_vars/stroom_and_proxy`.

#### Stack .env File

These variable files are used to set the values in the stack `.env` file. The
dict variable `stack_env_vars` is used for this purpose. Any entries in this
dict will be added into the `.env` file or will be used to replace the value of
an existing one. For example:

```yaml
stack_env_vars:

  DOCKER_HOST_HOSTNAME: "{{ inventory_hostname }}"
  DOCKER_HOST_IP: "{{ public_ip_address | default(ansible_default_ipv4) }}"

  DB_HOST_IP: "{{ stroom_db_host }}"
  STROOM_AUTH_DB_HOST: "{{ stroom_db_host }}"
```

#### Stroom .conf File

For non-docker deployments of stroom v6, the `stroom.conf` file can either be
configured using variables or using a Jinja2 template file. The choice will
depend on how much change is needed over the stock `stroom.conf` file, with the
former suiting minimal changes.

To modify the `stroom.conf` file using variables you need to define the
`stroom_conf_values` dict variable. For example:

```yaml
stroom_conf_values:

  - key: stroom.temp
    value: "/tmp/stroom"

  - key: stroom.node
    value: "{{ inventory_hostname_short }}"

  - key: stroom.htmlTitle
    value: "Test Stroom"
```

To modify the `stroom.conf` file using a Jinja2 template, create a
`stroom.conf.j2` template file in `files_and_templates/stroom/config/`.

### Files and Templates

The `files_and_templates` directory is used as a source of static files and
Jinja2 templates to copy/template onto the host.

This directory has a number of fixed sub-directories that map to locations on
the remote host.

* `stroom` => `<stroom home>/`, e.g. `~/stroom/v6.0.27/` 
* `stroom-proxy` => `<stroom-proxy home>/`, e.g. `~/stroom-proxy/v6.0.27/` 
* `volumes` => `<stack volumes dir>/`, e.g. `~/stroom_core/volumes/` 

Any files or directories in one of these directories will be mirrored onto
corresponding directory on the remote host. The relative path of the file in
these directories will be applied to the remote host. E.g. in a
_stroom_core_stack_:

`files_and_templates/volumes/nginx/conf/upstreams.proxy.conf.template.j2` => `~/stroom_core/volumes/nginx/conf/upstreams.proxy.conf.template` 

### Host Vars

Host specific variables can be set by creating files of the form
`host_vars/<inventory hostname>`.
