class razor::params {
  $source                = 'package'
  $primary_node_match    = [ 'mac' ]
  $secondary_node_match  = []
  $node_checkin_interval = '15'
  $task_path             = 'tasks'
  $broker_path           = 'brokers'
  $repo_store_root       = '/var/lib/razor/repo-store'
  $facts_blacklist       = [
    'domain',
    'filesystems',
    'fqdn',
    'hostname',
    'id',
    '/kernel.*/',
    'memoryfree',
    'memorysize',
    '/operatingsystem.*/',
    'osfamily',
    'path',
    'ps',
    'rubysitedir',
    'rubyversion',
    'selinux',
    'sshdsakey',
    '/sshfp_[dr]sa/',
    'sshrsakey',
    '/swap.*/',
    'timezone',
  ]
  $database_name         = 'razor_prod'
  $database_user         = 'razor'
  $database_pass         = 'r@z0r'

  $config_file = $razor::source ? {
    'package' => '/opt/razor-server/config.yaml',
    default   => '/opt/razor-server/config.yaml',
  }

  #We need libarchive
  $libarchive_package = $operatingsystem ? {
    "Ubuntu" => $operatingsystemrelease ? {
      /^12/ => 'libarchive12',
      /^13/ => 'libarchive13',
      default => undef
    },
    "Debian" => $operatingsystemmajrelease ? {
      '6' => 'libarchive1',
      '7' => 'libarchive12',
      default => 'libarchive13'
    },
  # We need the unversioned .so, which comes from the dev package on these
  # platforms; without that FFI fails to load the library. This naturally
  # depends on the regular library package in yum.
    "Fedora" => 'libarchive-devel',
    "RedHat" => 'libarchive-devel',
    "CentOS" => 'libarchive-devel',
    default => undef
  }

  if ! $libarchive_package {
    fail("unable to autodetect libarchive package name for your platform")
  }
}
