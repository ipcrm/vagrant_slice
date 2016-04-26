# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'yaml'
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'openstack'
cwd =  File.dirname(__FILE__)

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


# Validate Config
settings.each {|k,v|
        settings[k].each {|x,y|
                if y.nil?
                        abort("ERROR: #{k}.#{x} has no value in vagrant.yml! Cannot continue...exiting")
                end
        }
}

machine_count=settings['instances'].keys.length
Vagrant.configure(2) do |config|
    settings['instances'].keys.each {|i|

      autoup  = settings['instances'][i]['autoup']  ||= platforms[ settings['instances'][i]['platform'] ]['autoup']
      primary = settings['instances'][i]['primary'] ||= platforms[ settings['instances'][i]['platform'] ]['primary']
      config.vm.define i, primary: primary, autostart: autoup do |vmconfig|
        master_ip                           = settings['instances'][i]['master_ip'] ||= settings['defaults']['master_ip']
        vmconfig.vm.hostname                = settings['instances'][i]['name']
        vmconfig.vm.box                     = settings['instances'][i]['box']            ||= platforms[ settings['instances'][i]['platform'] ]['box']            ||= settings['instance_defaults']['box']
        vmconfig.vm.communicator            = settings['instances'][i]['communicator']   ||= platforms[ settings['instances'][i]['platform'] ]['communicator']   ||= settings['defaults']['communicator']
        vmconfig.winrm.username             = settings['instances'][i]['winrm_username'] ||= platforms[ settings['instances'][i]['platform'] ]['winrm_username'] ||= settings['defaults']['winrm_username']
        vmconfig.winrm.password             = settings['instances'][i]['winrm_password'] ||= platforms[ settings['instances'][i]['platform'] ]['winrm_password'] ||= settings['defaults']['winrm_password']
        vmconfig.ssh.username               = settings['instances'][i]['ssh_username']   ||= platforms[ settings['instances'][i]['platform'] ]['ssh_username']   ||= settings['defaults']['ssh_username']
        vmconfig.ssh.pty = true

        vmconfig.vm.provider :openstack do |provider,overrides|
          provider.openstack_auth_url     = settings['defaults']['openstack_auth_url']
          provider.username               = settings['defaults']['username']
          provider.password               = settings['defaults']['password']
          provider.tenant_name            = settings['defaults']['tenant_name']
          provider.keypair_name           = settings['defaults']['keypair_name']
          overrides.ssh.private_key_path  = settings['defaults']['private_key_path']

          provider.image                  = settings['instances'][i]['image']            ||= platforms[ settings['instances'][i]['platform'] ]['image']            ||= settings['instance_defaults']['image']
          provider.flavor                 = settings['instances'][i]['flavor']           ||= platforms[ settings['instances'][i]['platform'] ]['flavor']           ||= settings['instance_defaults']['flavor']
          provider.floating_ip_pool       = settings['instances'][i]['floating_ip_pool'] ||= platforms[ settings['instances'][i]['platform'] ]['floating_ip_pool'] ||= settings['instance_defaults']['floating_ip_pool']
          provider.networks               = settings['instances'][i]['networks']         ||= platforms[ settings['instances'][i]['platform'] ]['networks']         ||= settings['instance_defaults']['networks']
          provider.security_groups        = settings['instances'][i]['security_groups']  ||= platforms[ settings['instances'][i]['platform'] ]['security_groups']  ||= settings['instance_defaults']['security_groups']
          provider.sync_method            = settings['instances'][i]['sync_method']      ||= platforms[ settings['instances'][i]['platform'] ]['sync_method']      ||= settings['instance_defaults']['sync_method']
          provider.ssh_disabled           = settings['instances'][i]['ssh_disabled']     ||= platforms[ settings['instances'][i]['platform'] ]['ssh_disabled']     ||= settings['instance_defaults']['ssh_disabled']
          provider.user_data              = user_data[ platforms[ settings['instances'][i]['platform'] ]['user_data'] ].gsub("MASTERSERVER",master_ip)
        end

        vmroles = settings['instances'][i]['roles'] ||= platforms[ settings['instances'][i]['platform'] ]['roles']
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
