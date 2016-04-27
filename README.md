`vagrant_slice`
===============

1. [Overview](#overview)
2. [Setup](#setup)
    * [Prerequisites](#prerequisites)
    * [Defaults Configuration](#defaults-configuration)
    * [Platform Configuration](#platform-configuration)
    * [User Data Configuration](#user-data-configuration)
    * [Role Configuration](#role-configuration)

## Overview

The `vagrant_slice` repo lets you leverage the vagrant-openstack-provider with an OpenStack deploment.  In addition it's also configured (via the vagrantfile) to leverage vagrant-hosts for automated hosts file management (accross platforms).  This enviornment was originally designed to be used for creating puppet enviornments so you will see some reference to that (ie master-ip variable).

## Setup
Start by cloning this repo to your machine.

### Prerequisites
The following vagrant plugins are needed:

```
vagrant-hosts (2.8.0+)
vagrant-openstack-provider
vagrant-norequiretty
vagrant-triggers
```

### Defaults Configuration
To start, you're going to need to fill in your details in defaults.yml; the values in question:

```yaml
defaults:
  ssh_username:       <default username to use when ssh'ing to your instances (you can customize per image later)>
  openstack_auth_url: <OpenStack auth url - example: https://openstack-url:5000/v2.0>
  username:           <your openstack login username>
  password:           <your openstack login password>
  tenant_name:        <your tenant name in openstack>
  keypair_name:       <the keypair you want to use for new instance creation>
  private_key_path:   <the localpath to the private key for your keypair>
  communicator:       <default communicator.  Recommend setting this to ssh and overriding to winrm for windows(overrides are set elsewhere)>
  ssh_disabled:       <default status for ssh.  Recommend setting to false and overriding for windows to true (overrides are set elsewhere)>
  winrm_username:     <WinRM username to use with windows machines>
  winrm_password:     <WinRM password to use with windows machines>
  primary: false      <Default setting for if this should be the primary machine in a multi-master env.  This must be set to false, can override elsewhere>
  autoup: true        <Default setting for if the machine should be booted when an unqualified vagrant up is executed>
instance_defaults:
  flavor:             <Default openstack flavor to use for new instances without overrides>
  floating_ip_pool:   <Default floating-ip pool to use for machines without overrides>
  networks:           <An array of networks to be used for a new instance by default (example network is left just for show, replace it)>
    - network
  security_groups:    <An array of security groups to be used for a new instance by default (example default is left just for show, replace it)>
    - default
  box: 'dummy'        <The default box for vagrant.  Leave this set to dummy>
  sync_method: none   <The default sync method for vagrant.  Leave this to none by default and customize per image>
```

### Platform Configuration
A platform in terms of vagrant_slice represents the configuration settings required to stand up an instance with a specific image within your OpenStack deployment.

Example platform configuration:

```yaml
---
platforms:
  centos7:
    image: centos_7_x86_64
    sync_method: rsync
    user_data: centos

  debian8:
    image: debian_8.2.0_x86_64
    ssh_username: debian
    user_data: debian

  server2012:
    image: windows_2012_r2_std_eval_x86_64
    communicator: winrm
    ssh_disabled: true
    user_data: windows
    guest_type: windows
```

Per platform you can override any of the options declared in [Defaults](#defaults-configuration).

### Instance Configuration

An instance within vagrant_slice represents an actual vm that you will be managing via the vagrant toolset.

Example instance configuration:

```yaml
instances:
  centos7a.example.demo:
    platform: centos7

  debian1.example.demo:
    platform: debian8

  server2012r2a.example.demo:
    platform: server2012
    flavor: d1.medium
```

Just like platforms, you can override any of the options declared in [Defaults](#defaults-configuration); however your instance level overides take precedence over platform level overrides.

### User Data Configuration

Since we are leveraging images that use cloud-init, you can pass user_data scripts to those images via the user_data option.  User data is configured in config/user_data.yml.

Example snippet of user_data configuration:

```yaml
debian: |
    #!/bin/bash
    sed -i 's/Defaults    requiretty//g' /etc/sudoers
    apt-get update
    apt-get install -y curl
```

Please note that when passing powershell commands to windows its neccessary to enclose your script in <powershell></powershell> tags.

### Role configuration
Roles represent inline_shell commands you'd like vagrant to run during provisioning steps.  The are configured in config/roles.yml and can be specified on an instance or platforms by passing in an array within yaml.

Example instance with roles configured:

```yaml
instances:
  centos7a.example.demo:
    platform: centos7
    roles:
      - puppet_master
```

Example snippet of a role:
```yaml
roles:
  puppet_master: |
    set -ex
    cd /var/tmp
    curl -L -o puppet-enterpise-latest.tgz "https://pm.puppetlabs.com/cgi-bin/download.cgi?dist=el&rel=7&arch=x86_64&ver=latest"
    tar -zxvf puppet-enterpise-latest.tgz
    if [ -f /vagrant/answers.txt ]; then
    [..truncated..]
```


