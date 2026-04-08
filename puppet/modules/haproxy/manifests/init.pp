class haproxy {

  package { 'haproxy':
    ensure => installed,
  }

  file { '/etc/haproxy/haproxy.cfg':
    ensure  => file,
    content => @("EOF"),
      global
          log /dev/log local0
          maxconn 2000
          daemon

      defaults
          log     global
          mode    http
          option  httplog
          option  dontlognull
          timeout connect 5000
          timeout client  50000
          timeout server  50000

      listen stats
          bind *:8080
          stats enable
          stats uri /haproxy?stats
          stats auth admin:admin
          stats refresh 10s

      frontend http_front
          bind *:80
          acl is_users     path_beg /api/users
          acl is_products  path_beg /products
          acl is_orders    path_beg /api/orders
          use_backend users_back    if is_users
          use_backend products_back if is_products
          use_backend orders_back   if is_orders

      backend users_back
          balance roundrobin
          server users1 192.168.100.3:5002 check
          server users2 192.168.100.3:5012 check

      backend products_back
          balance roundrobin
          server products1 192.168.100.3:5003 check
          server products2 192.168.100.3:5013 check

      backend orders_back
          balance roundrobin
          server orders1 192.168.100.3:5004 check
          server orders2 192.168.100.3:5014 check
      | EOF

    require => Package['haproxy'],
    notify  => Service['haproxy'],
  }

  service { 'haproxy':
    ensure  => running,
    enable  => true,
    require => Package['haproxy'],
  }
}