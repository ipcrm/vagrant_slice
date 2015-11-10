vagrant
=======

Vagrant Setup

Usage
=====
Step 1
------
Configure vagrant.yml.  In this file the "name" and "r10k_path" are blank.  You need to populate both of these fields.  For this vagrant machine, you should be running r10k locally and downloading to a directory(see the included r10k.yaml.example file).  The base directory for r10k is what you should include in your r10k_path config.  

Step 2
------
Simply run vagrant up.

Step 3
------
Your first puppet run.  Puppet on the VM has been configured to use the /vagrant/hiera.yaml file so that hieradata works in vagrant just like it would in the real master environment.  Also, there is a init.pp file included in the repo - this file should be used to specify what modules to include in the run(ie the modules your testing).  It also has the required pieces of site.pp from the production environment. 

Example:

puppet apply --environment=ENVNAME /vagrant/init.pp

Continue to edit init.pp as desired to do whatever testing you like.
