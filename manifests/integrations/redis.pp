# Class: datadog_agent::integrations::redis
#
# This class will install the necessary configuration for the redis integration
#
# Parameters:
#   $host:
#       The host redis is running on
#   $password
#       The redis password (optional)
#   $port
#       The main redis port.
#   $ports
#       Array of redis ports: overrides port (optional)
#   $slowlog_max_len
#       The max length of the slow-query log (optional)
#   $tags
#       Optional array of tags
#   $keys
#       Optional array of keys to check length
#   $command_stats
#       Collect INFO COMMANDSTATS output as metrics
#   $ ssl_ca_certs
#       Location of SSL certificate authority (CA) file (optional)
#   $ssl_cert_file
#       Location of the client-side SSL certificate file (optional)
#   $ssl_cert_reqs
#       Whether or not a certificate is required from the other side of the
#       connection, and if it will be validated if provided (optional)
#   $ssl_keyfile
#       Location of the client-side private key file (optional)
#   $ssl_enabled
#       Enable SSL/TSL support (optional)
#
# Sample Usage:
#
#  class { 'datadog_agent::integrations::redis' :
#    host => 'localhost',
#  }
#
#
class datadog_agent::integrations::redis(
  String $host                              = 'localhost',
  String $password                          = '',
  Variant[String, Integer] $port            = '6379',
  Optional[Array] $ports                    = undef,
  Variant[String, Integer] $slowlog_max_len = '',
  Array $tags                               = [],
  Array $keys                               = [],
  Boolean $warn_on_missing_keys             = true,
  Boolean $command_stats                    = false,
  String $ssl_ca_certs                      = '',
  String $ssl_certfile                      = '',
  String $ssl_cert_reqs                     = '',
  Boolean $ssl_enabled                      = false,
  String $ssl_keyfile                       = '',

) inherits datadog_agent::params {
  include datadog_agent

  validate_legacy('Array', 'validate_array', $tags)
  validate_legacy('Array', 'validate_array', $keys)
  validate_legacy('Boolean', 'validate_bool', $warn_on_missing_keys)
  validate_legacy('Boolean', 'validate_bool', $command_stats)
  validate_legacy('Optional[Array]', 'validate_array', $ports)
  validate_legacy('Boolean', 'validate_bool', $ssl_enabled)
  validate_legacy('Optional[String]', 'validate_string', $ssl_ca_certs)
  validate_legacy('Optional[String]', 'validate_string', $ssl_certfile)
  validate_legacy('Optional[String]', 'validate_string', $ssl_cert_reqs)
  validate_legacy('Optional[String]', 'validate_string', $ssl_keyfile)

  if $ports == undef {
    $_ports = [ $port ]
  } else {
    $_ports = $ports
  }

  validate_legacy('Array', 'validate_array', $_ports)

  $legacy_dst = "${datadog_agent::conf_dir}/redisdb.yaml"
  if !$::datadog_agent::agent5_enable {
    $dst = "${datadog_agent::conf6_dir}/redisdb.d/conf.yaml"
    file { $legacy_dst:
      ensure => 'absent'
    }
  } else {
    $dst = $legacy_dst
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/redisdb.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
