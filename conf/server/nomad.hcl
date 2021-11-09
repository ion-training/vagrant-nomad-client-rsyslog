datacenter = "dc1"
data_dir = "/opt/nomad"

bind_addr = "192.168.56.71"

advertise {
  http = "192.168.56.71"
}

server {
  enabled = true
  bootstrap_expect = 1
}
