class razor::config (
  $dest                  = $razor::params::dest,
  $primary_node_match    = $razor::params::primary_node_match,
  $secondary_node_match  = $razor::params::secondary_node_match,
  $node_checkin_interval = $razor::params::node_checkin_interval,
  $task_path             = $razor::params::task_path,
  $broker_path           = $razor::params::broker_path,
  $repo_store_root       = $razor::params::repo_store_root,
  $facts_blacklist       = $razor::params::facts_blacklist,
  $prd_database_host     = undef,
  $prd_database_name     = $razor::params::database_name,
  $prd_database_user     = $razor::params::database_user,
  $prd_database_pass     = $razor::params::database_pass,
  $dev_database_host     = undef,
  $dev_database_name     = undef,
  $dev_database_user     = undef,
  $dev_database_pass     = undef,
  $tst_database_host     = undef,
  $tst_database_name     = undef,
  $tst_database_user     = undef,
  $tst_database_pass     = undef,
) inherits razor::params {

  file { "${dest}/config.yaml" :
    ensure  => file, owner => root, group => root, mode => 0755,
    content => template('razor/config.yaml.erb'),
    notify  => Service['razor-server'],
  }

}
