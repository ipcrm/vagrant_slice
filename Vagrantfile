# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'yaml'

# Load Config
settings = YAML.load_file 'config/vagrant.yml'
role_config = YAML.load_file 'config/roles.yml'
roles = role_config['roles']
userdata_raw = YAML.load_file 'config/user_data.yml'
user_data = userdata_raw['userdata']



# Validate Config
settings.each {|k,v|
        settings[k].each {|x,y|
                if y.nil?
                        abort("ERROR: #{k}.#{x} has no value in vagrant.yml! Cannot continue...exiting")
                end
        }
}

Vagrant.configure(2) do |config|
    settings['instances'].keys.each {|i|
      config.vm.define i, primary: settings['instances'][i]['primary'], autostart: settings['instances'][i]['autoup'] do |vmconfig|
        master_ip = settings['instances'][i]['master_ip'] ||= settings['defaults']['master_ip']
        vmconfig.vm.box                     = settings['instances'][i]['box']
        vmconfig.vm.hostname                = settings['instances'][i]['name']
        vmconfig.vm.communicator            = settings['instances'][i]['communicator']   ||= settings['defaults']['communicator']
        vmconfig.winrm.username             = settings['instances'][i]['winrm_username'] ||= settings['defaults']['winrm_username']
        vmconfig.winrm.password             = settings['instances'][i]['winrm_password'] ||= settings['defaults']['winrm_password']
        vmconfig.ssh.username               = settings['instances'][i]['ssh_username']   ||= settings['defaults']['ssh_username']
        vmconfig.ssh.pty = true

        vmconfig.vm.provider :openstack do |provider,overrides|
          provider.openstack_auth_url     = settings['defaults']['openstack_auth_url']
          provider.username               = settings['defaults']['username']
          provider.password               = settings['defaults']['password']
          provider.tenant_name            = settings['defaults']['tenant_name']
          provider.keypair_name           = settings['defaults']['keypair_name']
          overrides.ssh.private_key_path  = settings['defaults']['private_key_path']

          provider.image                  = settings['instances'][i]['image']
          provider.flavor                 = settings['instances'][i]['flavor']           ||= settings['instance_defaults']['flavor']
          provider.floating_ip_pool       = settings['instances'][i]['floating_ip_pool'] ||= settings['instance_defaults']['floating_ip_pool']
          provider.networks               = settings['instances'][i]['networks']         ||= settings['instance_defaults']['networks']
          provider.security_groups        = settings['instances'][i]['security_groups']  ||= settings['instance_defaults']['security_groups']
          provider.sync_method            = settings['instances'][i]['sync_method']      ||= settings['instance_defaults']['sync_method']
          provider.ssh_disabled           = settings['instances'][i]['ssh_disabled']     ||= settings['instance_defaults']['ssh_disabled']
          if settings['instances'][i].has_key?('user_data')
            provider.user_data = user_data[settings['instances'][i]['user_data']].gsub("MASTERSERVER",master_ip)
          end
        end

        vmroles = settings['instances'][i]['roles'] ||= settings['instance_defaults']['roles']
        vmroles.each {|r|
          if roles.key?(r)
            vmconfig.vm.provision "shell",
              inline: roles[r].gsub("MASTERSERVER",master_ip)
          else
            abort("Error: VM #{i} configured role #{r} is not valid! Existing...")
          end
        }
      end
    }
end
