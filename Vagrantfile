# -*- mode: ruby -*-
# vi: set ft=ruby :

# Ensure that VirtualBox is used for these VMs
# Without this setting, you need to include " --provider virtualbox" 
# if you have vmware provider available as well.
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
    config.vm.define settings['vm']['name'], primary: settings['vm']['primary'], autostart: settings['vm']['autoup'] do |config|
      config.vm.box                     = settings['box']['name']
      config.vm.hostname                = settings['vm']['name']
      config.ssh.username               = settings['defaults']['ssh_username']

      config.vm.provider :openstack do |provider,overrides|
        provider.openstack_auth_url     = settings['defaults']['openstack_auth_url']
        provider.username               = settings['defaults']['username']
        provider.password               = settings['defaults']['password']
        provider.tenant_name            = settings['defaults']['tenant_name']

        provider.flavor                 = settings['vm']['flavor']
        provider.image                  = settings['vm']['image']
        provider.floating_ip_pool       = settings['defaults']['floating_ip_pool']
        provider.networks               = settings['defaults']['networks']
        provider.security_groups        = settings['defaults']['security_groups']

        provider.keypair_name           = settings['defaults']['keypair_name']
        overrides.ssh.private_key_path  = settings['defaults']['private_key_path']
      end
  end
end



