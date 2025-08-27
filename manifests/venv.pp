# @summary Create a uv virtual environment
#
# A description of what this defined type does
#
# @example
#   uv::venv { 'jupyterhub': 
#     prefix => '/opt/jupyterhub',
#     python => '3.12',
#   }
define uv::venv (
  String $prefix,
  Variant[Stdlib::Absolutepath, String] $python,
  Hash[String, Variant[String, Integer, Array[String]]] $pip_environment = {},
  Optional[String] $requirements = undef,
  Optional[Stdlib::Absolutepath] $requirements_path = undef,
) {
  include uv::install

  $uv_prefix = lookup('uv::install::prefix')

  $pip_env_list = $pip_environment.reduce([]) |Array $list, Array $value| {
    if $value[1] =~ Stdlib::Compat::Array {
      $concat = $value[1].reduce('') | String $concat, String $token | {
        "${token}:${concat}"
      }
      $list + ["${value[0]}=${concat}"]
    }
    else {
      $list + ["${value[0]}=${value[1]}"]
    }
  }

  if $python =~ Stdlib::Absolutepath {
    $path    = ["${uv_prefix}/bin", dirname($python),'/bin', '/usr/bin']
    $environ = []
  } else {
    $path    = ["${uv_prefix}/bin"]
    $environ = ["XDG_DATA_HOME=${uv_prefix}/share"]
  }

  exec { "${name}_venv":
    command     => "uv venv --seed -p ${python} ${prefix}",
    creates     => "${prefix}/bin/python",
    require     => Class['uv::install'],
    path        => $path,
    environment => $environ,
  }

  if 'PIP_CONFIG_FILE' in $pip_environment {
    $pip_cmd = 'pip install'
    $pip_environ = $pip_env_list
    $pip_path = ["${prefix}/bin"]
  } else {
    $pip_cmd = 'uv pip install'
    $pip_environ = $pip_env_list + ["VIRTUAL_ENV=${prefix}"]
    $pip_path = ["${uv_prefix}/bin"]
  }

  file { "${prefix}/${name}-requirements.1.txt":
    ensure => file,
  }
  if $requirements_path {
    File["${prefix}/${name}-requirements.1.txt"] {
      source => "file://${requirements_path}",
      notify => Exec["${name}_pip_install"],
    }
  }

  file { "${prefix}/${name}-requirements.2.txt":
    ensure => file,
  }
  if $requirements {
    File["${prefix}/${name}-requirements.2.txt"] {
      content => $requirements,
      notify  => Exec["${name}_pip_install"],
    }
  }

  exec { "${name}_pip_install":
    command     => "${pip_cmd} -r ${prefix}/${name}-requirements.1.txt -r ${prefix}/${name}-requirements.2.txt",
    refreshonly => true,
    environment => $pip_environ,
    timeout     => 0,
    path        => $pip_path,
    require     => Exec["${name}_venv"],
  }
}
