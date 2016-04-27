source 'https://rubygems.org'

# Local additions and environment variable overrides can be placed in:
#     Gemfile.local
eval(File.read("#{__FILE__}.local"), binding) if File.exists? "#{__FILE__}.local"

gem 'vagrant', :github => 'mitchellh/vagrant', :tag => 'v1.8.1'

# Gems listed in this group are automatically loaded by the Vagrantfile which
# simulates the action of `vagrant plugin`, which is inactive when running
# under Bundler.
group :plugins do
  gem 'oscar', '>= 0.5'
  gem 'vagrant-hosts', '>= 2.8.0'
  gem 'vagrant-vsphere', '>= 1.7.0'
  gem 'vagrant-openstack-provider', :github => 'ipcrm/vagrant-openstack-provider', :ref => 'master'
  gem 'vagrant-norequiretty'
end
