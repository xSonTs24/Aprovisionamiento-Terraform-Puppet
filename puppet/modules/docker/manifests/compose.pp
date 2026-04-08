class docker::compose {

  file { '/home/vagrant/app':
    ensure => directory,
    owner  => 'vagrant',
    group  => 'vagrant',
  }

  file { '/home/vagrant/app/docker-compose.yml':
    ensure  => file,
    owner   => 'vagrant',
    group   => 'vagrant',
    source => '/home/vagrant/Microservicios/docker-compose.yml',
    require => File['/home/vagrant/app'],
  }

  exec { 'copy-microservicios':
    command => 'cp -r /home/vagrant/Microservicios/. /home/vagrant/app/',
    path    => ['/usr/bin', '/bin'],
    require => File['/home/vagrant/app'],
    before  => Exec['docker-compose-up'],
  }

  exec { 'docker-compose-up':
    command     => 'docker compose up -d --build',
    path        => ['/usr/bin', '/usr/local/bin'],
    cwd         => '/home/vagrant/app',
    environment => ['HOME=/home/vagrant'],
    timeout     => 600,
    require     => [
      Class['docker'],
      File['/home/vagrant/app/docker-compose.yml'],
      Exec['copy-microservicios'],
    ],
  }

  file { '/etc/systemd/system/app-compose.service':
    ensure  => file,
    content => "[Unit]\nDescription=App microservicios docker compose\nRequires=docker.service\nAfter=docker.service\n\n[Service]\nType=oneshot\nRemainAfterExit=yes\nWorkingDirectory=/home/vagrant/app\nExecStart=/usr/bin/docker compose up -d\nExecStop=/usr/bin/docker compose down\nUser=vagrant\n\n[Install]\nWantedBy=multi-user.target\n",
    require => Exec['docker-compose-up'],
  }

  exec { 'systemd-reload':
    command     => 'systemctl daemon-reload',
    path        => ['/usr/bin', '/bin'],
    subscribe   => File['/etc/systemd/system/app-compose.service'],
    refreshonly => true,
  }

  service { 'app-compose':
    ensure  => running,
    enable  => true,
    require => [
      File['/etc/systemd/system/app-compose.service'],
      Exec['systemd-reload'],
    ],
  }
}