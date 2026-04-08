class docker {

  # Instala dependencias
  package { ['ca-certificates', 'curl', 'gnupg', 'lsb-release']:
    ensure => installed,
  }

  # Agrega la llave GPG de Docker
  exec { 'add-docker-gpg':
    command => 'curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg',
    path    => ['/usr/bin', '/bin'],
    creates => '/usr/share/keyrings/docker-archive-keyring.gpg',
    require => Package['curl'],
  }

  # Agrega el repositorio
  exec { 'add-docker-repo':
    command => 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu jammy stable" | tee /etc/apt/sources.list.d/docker.list',
    path    => ['/usr/bin', '/bin'],
    creates => '/etc/apt/sources.list.d/docker.list',
    require => Exec['add-docker-gpg'],
  }

  exec { 'apt-update-docker':
    command     => 'apt-get update',
    path        => ['/usr/bin', '/bin'],
    refreshonly => true,
    subscribe   => Exec['add-docker-repo'],
  }

  # Instala Docker
  package { ['docker-ce', 'docker-ce-cli', 'containerd.io', 'docker-compose-plugin']:
    ensure  => installed,
    require => Exec['apt-update-docker'],
  }

  # Habilita y arranca Docker
  service { 'docker':
    ensure  => running,
    enable  => true,
    require => Package['docker-ce'],
  }

  # Agrega vagrant al grupo docker
  exec { 'add-vagrant-to-docker':
    command => 'usermod -aG docker vagrant',
    path    => ['/usr/sbin', '/usr/bin'],
    unless  => 'id -nG vagrant | grep -qw docker',
    require => Service['docker'],
  }
}