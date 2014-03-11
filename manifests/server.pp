class razor::server (
  $url      = 'http://links.puppetlabs.com/razor-server-latest.zip',
  $dest     = '/opt/razor',
  $revision = 'master',
  $prd_database_host     = undef,
  $prd_database_name     = 'razor',
  $prd_database_user     = 'razor',
  $prd_database_pass     = 'r@z0r',
  $dev_database_host     = undef,
  $dev_database_name     = undef,
  $dev_database_user     = undef,
  $dev_database_pass     = undef,
  $tst_database_host     = undef,
  $tst_database_name     = undef,
  $tst_database_user     = undef,
  $tst_database_pass     = undef,
){

  if $url =~ /\.git$/ {
    ensure_resource( 'package', 'git', { ensure => 'latest' } )
    vcsrepo { 'razor-server':
      ensure   => 'latest',
      provider => 'git',
      path     => $dest,
      source   => $url,
      owner    => 'root',
      group    => 'root',
      revision => $revision,
      require  => Package['git'],
      before   => [ 
        Exec["deploy razor if it was undeployed"],
        Exec["deploy razor to torquebox"],
        File["${dest}/bin/razor-binary-wrapper"],
        File["${dest}/bin/razor-admin"],
        File["${dest}/bin/razor-admin"],
        File["${dest}/log"],
      ],
    }
  }
  else {
    # Put the archive into place, if needed.
    exec { "install razor binary distribution to ${dest}":
      provider => shell,
      command  => template('razor/install-zip.sh.erb'),
      path     => '/bin:/usr/bin:/usr/local/bin:/opt/bin',
      creates  => "${dest}/bin/razor-admin",
      require  => [Package[curl], Package[unzip]],
      notify   => Exec["deploy razor to torquebox"]
      before   => [ 
        Exec["deploy razor if it was undeployed"],
        Exec["deploy razor to torquebox"],
        File["${dest}/bin/razor-binary-wrapper"],
        File["${dest}/bin/razor-admin"],
        File["${dest}/bin/razor-admin"],
        File["${dest}/log"],
      ],
    }
  }

  if ! $prd_database_host or $prd_database_host == $::fqdn or $prd_database_host == $::ipaddress {
    class { 'razor::database' :
      prd_database_name => $prd_database_name,
      prd_database_user => $prd_database_user,
      prd_database_pass => $prd_database_pass,
      dev_database_name => $dev_database_name,
      dev_database_user => $dev_database_user,
      dev_database_pass => $dev_database_pass,
      tst_database_name => $tst_database_name,
      tst_database_user => $tst_database_user,
      tst_database_pass => $tst_database_pass,
    }
  }

  exec { "deploy razor if it was undeployed":
    provider => shell,
    unless   => "test -f ${razor::torquebox::dest}/jboss/standalone/deployments/razor-knob.yml",
    # This is actually "notify if the file does not exist" :)
    command  => ":",
    notify   => Exec["deploy razor to torquebox"],
  }

  # deploy razor, if required.
  exec { "deploy razor to torquebox":
    command     => "${razor::torquebox::dest}/jruby/bin/torquebox deploy --env production",
    cwd         => $dest,
    environment => [
      "TORQUEBOX_HOME=${razor::torquebox::dest}",
      "JBOSS_HOME=${razor::torquebox::dest}/jboss",
      "JRUBY_HOME=${razor::torquebox::dest}/jruby"
    ],
    path        => "${razor::torquebox::dest}/jruby/bin:/bin:/usr/bin:/usr/local/bin",
    refreshonly => true
  }

  file { "${dest}/config.yaml" :
    ensure  => file, owner => root, group => root, mode => 0755,
    content => template('razor/config.yaml.erb'),
  }

  file { "${dest}/bin/razor-binary-wrapper":
    ensure  => file, owner => root, group => root, mode => 0755,
    content => template('razor/razor-binary-wrapper.erb'),
  }

  file { "/usr/local/bin/razor-admin":
    ensure => link, target => "${dest}/bin/razor-binary-wrapper"
  }

  # Work around what seems very much like a bug in the package...
  file { "${dest}/bin/razor-admin":
    mode    => 0755,
  }

  file { "/var/lib/razor":
    ensure => directory, owner => razor-server, group => razor-server, mode => 0775,
  }

  file { "/var/lib/razor/repo-store":
    ensure => directory, owner => razor-server, group => razor-server, mode => 0775
  }

  file { "${dest}/log":
    ensure  => directory, owner => razor-server, group => razor-server, mode => 0775,
  }

  file { "${dest}/log/production.log":
    ensure  => file, owner => razor-server, group => razor-server, mode => 0660
  }
}
