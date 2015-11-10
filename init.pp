node default {
  # For Vagrant, treat this as your "role" definition
  # or put your classes in hiera
}

Package {
  allow_virtual => true,
}

### Allow Hiera to drive class inclusion
#hiera_include('classes')

