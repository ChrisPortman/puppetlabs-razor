# Class: razor
#
# Parameters:
#
# [*servername*]: the DNS name or IP address of the Razor server (default: `$fqdn`)
# [*libarchive*]: the name of the libarchive package.  (default: autodetect)
# [*tftp*]: should TFTP services be installed and configured on this machine? (default: true)
#
# Actions:
#
#   Installs and runs the razor-server, along with all dependencies.
#
# Usage:
#
#   include razor
#
class razor (
  $servername        = $fqdn,
  $libarchive        = undef,
  $tftp              = true,
  $url               = 'http://links.puppetlabs.com/razor-server-latest.zip',
  $revision          = 'master',
  $dest              = '/opt/razor',
  $prd_database_host = undef,
  $prd_database_name = undef',
  $prd_database_user = undef,
  $prd_database_pass = undef,
  $dev_database_host = undef,
  $dev_database_name = undef,
  $dev_database_user = undef,
  $dev_database_pass = undef,
  $tst_database_host = undef,
  $tst_database_name = undef,
  $tst_database_user = undef,
  $tst_database_pass = undef,
) {
  # Ensure libarchive is installed -- the users requested custom version, or
  # our own guesswork as to what the version is on this platform.
  if $libarchive {
    package { $libarchive: ensure => latest }
  } else {
    include razor::libarchive
  }

  package { "unzip": ensure => latest }
  package { "curl":  ensure => latest }

  # Install a JVM, since we need one
  include 'java'
  Class[java] -> Class[Razor::TorqueBox]

  # Install our own TorqueBox bundle, quietly.  This isn't intended to be
  # shared with anyone else, so we don't use a standard module.
  include 'razor::torquebox'

  # Once that is installed, we also need to install the server software.
  class { 'razor::server' :
    url      => $url,
    revision => $revision,
    dest     => $dest,
  }

  Class[Razor::Torquebox] -> Class[Razor::Server]

  if $tftp {
    class { 'razor::tftp':
      server => $servername
    }
  }
}
