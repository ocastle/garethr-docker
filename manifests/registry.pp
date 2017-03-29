# == Class: docker::registry
#
# Module to configure private docker registries from which to pull Docker images
# If the registry does not require authentication, this module is not required.
#
# === Parameters
# [*server*]
#   The hostname and port of the private Docker registry. Ex: dockerreg:5000
#
# [*homedir*]
#   Home directory of the use to configure the docker registry credentials for.
#   Default: '/root'
#
# [*ensure*]
#   Whether or not you want to login or logout of a repository
#   Default: 'present'
#
# [*username*]
#   Username for authentication to private Docker registry.  Required if ensure
#   is set to present.
#
# [*password*]
#   Password for authentication to private Docker registry. Required if ensure
#   is set to present.
#
# [*email*]
#   Email for registration to private Docker registry. Required if ensure is
#   set to present.
#
# [*show_diff*]
#   Whether or not to show diff when applying augeas resources.  Setting this
#   to true may expose sensitive information.
#   Default: false
#
define docker::registry(
  $server      = $title,
  $ensure      = 'present',
  $username    = undef,
  $password    = undef,
  $email       = undef,
  $local_user  = 'root',
  $show_diff   = false,
) {
  include docker::params

  validate_re($ensure, '^(present|absent)$')

  $docker_command = $docker::params::docker_command

  if $ensure == 'present' {
    if $username != undef and $password != undef and $email != undef {
      $auth_cmd = "${docker_command} login -u '${username}' -p \"\${password}\" -e '${email}' ${server}"
      $auth_environment = "password=${password}"
    }
    else {
      $auth_cmd = "${docker_command} login ${server}"
      $auth_environment = undef
    }
  }
  else {
    $auth_cmd = "${docker_command} logout ${server}"
    $auth_environment = undef
  }

  $auth_string = base64('encode', "${username}:${password}", 'strict')

  exec { "${title} auth":
    environment => $auth_environment,
    command     => $auth_cmd,
    path        => [ '/usr/local/bin/', '/usr/bin/', '/bin/' ],
    unless      => "grep -qPaz '(^.*)\"auths\": {\\n.*\"${server}\": {\\n\\s+\"auth\": \"${auth_string}\"' ~${local_user}/.docker/config.json",
    user        => $local_user,
    cwd         => '/root',
    path        => ['/bin', '/usr/bin'],
    timeout     => 0,
  }

}
