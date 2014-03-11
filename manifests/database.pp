class razor::database (
  $postgres_password = 'postgr3s',
  $prd_database_name = 'razor',
  $prd_database_user = 'razor',
  $prd_database_pass = 'r@z0r',
  $dev_database_name = undef,
  $dev_database_user = undef,
  $dev_database_pass = undef,
  $tst_database_name = undef,
  $tst_database_user = undef,
  $tst_database_pass = undef,
) {
  class { 'postgresql::server' :
    listen_addresses  => '*',
    postgres_password => 'flubbleROT9',
    needs_initdb      => true,
  }

  if $prd_database_name and $prd_database_user and $prd_database_pass {
    postgresql::server::db { $prd_database_name :
      user     => $prd_database_user,
      password => $prd_database_pass,
    }
  } 

  if $dev_database_name and $dev_database_user and $dev_database_pass {
    postgresql::server::db { $dev_database_name :
      user     => $dev_database_user,
      password => $dev_database_pass,
    }
  } 

  if $tst_database_name and $tst_database_user and $tst_database_pass {
    postgresql::server::db { $tst_database_name :
      user     => $tst_database_user,
      password => $tst_database_pass,
    }
  } 
}
