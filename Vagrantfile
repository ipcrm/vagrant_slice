# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'yaml'

# Load Config
settings = YAML.load_file 'vagrant.yml'

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
        vmconfig.vm.box                     = settings['instances'][i]['box']
        vmconfig.vm.hostname                = settings['instances'][i]['name']
        vmconfig.ssh.username               = settings['instances'][i]['ssh_username'] ||= settings['defaults']['ssh_username']

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
        end
      end
    }
end
