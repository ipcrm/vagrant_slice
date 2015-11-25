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
      # ###################
      # Use downloaded box name
      config.vm.box = settings['box']['name']
      config.vm.hostname = settings['vm']['name']


      # ###################
      # Use VBoxManage to customize the VM
      # --
      config.vm.provider "vmware_fusion" do |vb|
        #vb.gui = true
        vb.vmx["numvcpus"] = settings['vm']['cpus'] if settings['vm']['cpus']
        vb.vmx["memsize"] = settings['vm']['mem']  if settings['vm']['mem']
      end

      # ##################
      # Setup forwarded TCP ports  
      settings['tcp_ports'].each {|vport,hport|
	config.vm.network "forwarded_port", guest: vport, host: hport, protocol: 'tcp'
      } if settings['tcp_ports']

      # ##################
      # Setup forwarded UDP ports  
      settings['udp_ports'].each {|vport,hport|
	config.vm.network "forwarded_port", guest: vport, host: hport, protocol: 'udp'
      } if settings['udp_ports']

      # ###################
      # Setup Puppet sync'd folders
      config.vm.synced_folder settings['host']['r10k_path'], "/tmp/r10k"
    end
end



