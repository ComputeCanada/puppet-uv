# @summary Install Astral uv
# @example
#   include uv::install
class uv::install (
  String $prefix,
  String $version,
) {
  ensure_resource('file', $prefix, { 'ensure' => 'directory' })
  ensure_resource('file', "${prefix}/bin", { 'ensure' => 'directory', require => File[$prefix] })
  $arch = $::facts['os']['architecture']
  archive { 'install_uv':
    path            => '/tmp/uv',
    source          => "https://github.com/astral-sh/uv/releases/download/${version}/uv-${arch}-unknown-linux-gnu.tar.gz",
    extract         => true,
    extract_path    => "${prefix}/bin",
    extract_command => 'tar xfz %s --strip-components=1',
    creates         => "${$prefix}/bin/uv",
    cleanup         => true,
    require         => File["${prefix}/bin"],
  }
}
