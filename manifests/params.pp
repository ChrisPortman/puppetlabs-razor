class razor::params {
  $source                = 'package'
  $dest                  = '/opt/razor'
  $primary_node_match    = [ 'mac' ]
  $secondary_node_match  = []
  $node_checkin_interval = '15'
  $task_path             = 'tasks'
  $broker_path           = 'brokers'
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
}
