class consul {

  exec { 'wait-for-consul':
    command => 'bash -c "for i in {1..30}; do curl -s http://localhost:8500/v1/status/leader && break || sleep 3; done"',
    path    => ['/usr/bin', '/bin'],
  }

}