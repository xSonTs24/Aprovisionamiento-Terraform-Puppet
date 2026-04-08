node default {
  include docker
  include docker::compose
  include haproxy
  include consul
}