# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'yaml'
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'openstack'
cwd =  File.dirname(__FILE__)

def missing_setting(setting,machine)
  abort("ERROR: Missing setting [#{setting}] for machine [#{machine}]")
end

def get_settings(platforms,settings,instance,setting)
  # Instance Override
  if settings['instances'][instance][setting] != nil
    return settings['instances'][instance][setting]

  # Platform Setting
  elsif platforms[ settings['instances'][instance]['platform'] ][setting] != nil
    return platforms[ settings['instances'][instance]['platform'] ][setting]

  # Global Instance Default
  elsif settings['instance_defaults'][setting] != nil
    return settings['instance_defaults'][setting]

  # Global Default
  elsif settings['defaults'][setting] != nil
    return settings['defaults'][setting]

  # Fail out, required setting is missing
  else
    # If this is not the 'roles' setting, fail.  
    #  Roles can be empty
    if setting != 'roles' && setting != 'guest_type'
      missing_setting(setting,instance)
    end
  end
end

# Load Config
settings              = YAML.load_file cwd + '/config/default.yml'
instance_raw          = YAML.load_file cwd + '/config/instances.yml'
userdata_raw          = YAML.load_file cwd + '/config/user_data.yml'
role_raw              = YAML.load_file cwd + '/config/roles.yml'
platform_raw          = YAML.load_file cwd + '/config/platforms.yml'

instances             = instance_raw['instances']
settings['instances'] = instances
roles                 = role_raw['roles']
user_data             = userdata_raw['userdata']
platforms             = platform_raw['platforms']


Vagrant.configure(2) do |config|
    settings['instances'].keys.each {|i|
      config.vm.define i, primary: get_settings(platforms,settings,i,'primary'), autostart: get_settings(platforms,settings,i,'autoup') do |vmconfig|
        vmconfig.vm.hostname              = settings['instances'][i]['name']
        vmconfig.vm.box                   = get_settings(platforms,settings,i,'box')
        vmconfig.vm.communicator          = get_settings(platforms,settings,i,'communicator')
        vmconfig.winrm.username           = get_settings(platforms,settings,i,'winrm_username')
        vmconfig.winrm.password           = get_settings(platforms,settings,i,'winrm_password')
        vmconfig.ssh.username             = get_settings(platforms,settings,i,'ssh_username')
        vmconfig.ssh.pty                  = true
        master_ip                         = get_settings(platforms,settings,i,'master_ip')

        if get_settings(platforms,settings,i,'guest_type') != nil
          vmconfig.vm.guest = get_settings(platforms,settings,i,'guest_type')
        end

        vmconfig.vm.provider :openstack do |provider,overrides|
          provider.openstack_auth_url     = get_settings(platforms,settings,i,'openstack_auth_url')
          provider.username               = get_settings(platforms,settings,i,'username')
          provider.password               = get_settings(platforms,settings,i,'password')
          provider.tenant_name            = get_settings(platforms,settings,i,'tenant_name')
          provider.keypair_name           = get_settings(platforms,settings,i,'keypair_name')
          overrides.ssh.private_key_path  = get_settings(platforms,settings,i,'private_key_path')

          provider.image                  = get_settings(platforms,settings,i,'image')
          provider.flavor                 = get_settings(platforms,settings,i,'flavor')
          provider.floating_ip_pool       = get_settings(platforms,settings,i,'floating_ip_pool')
          provider.networks               = get_settings(platforms,settings,i,'networks')
          provider.security_groups        = get_settings(platforms,settings,i,'security_groups')
          provider.sync_method            = get_settings(platforms,settings,i,'sync_method')
          provider.ssh_disabled           = get_settings(platforms,settings,i,'ssh_disabled')
          provider.user_data              = user_data[ get_settings(platforms,settings,i,'user_data') ].gsub("MASTERSERVER",master_ip)
        end

        vmconfig.vm.provision :hosts do |provisioner|
          provisioner.sync_hosts = true
          provisioner.autoconfigure = true
          provisioner.exports = {
            'global' => [
              ['@facter_ipaddress', ['@vagrant_hostnames']],
            ],
          }
          provisioner.imports = ['global']
        end

        vmroles = get_settings(platforms,settings,i,'roles')
        if vmroles
          vmroles.each {|r|
            if roles.key?(r)
              vmconfig.vm.provision "shell",
                inline: roles[r].gsub("MASTERSERVER",master_ip)
            else
              abort("Error: VM #{i} configured role #{r} is not valid! Existing...")
            end
          }
      end

      if Vagrant.has_plugin?("vagrant-triggers")
        vmconfig.trigger.after :destroy do
          run "vagrant ssh /master/ -c 'sudo -i puppet node purge " + i + "'"
        end
      end

      end
    }


end
