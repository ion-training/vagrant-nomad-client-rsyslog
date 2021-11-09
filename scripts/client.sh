#!/usr/bin/env bash

echo ${HOSTNAME}

# ENVIRONMENT VARIABLES #
#########################
export DEBIAN_FRONTEND=noninteractive
export NOMAD_VERSION="1.1.6"
export ARCH="amd64"

# Nomad download#
#################
curl --silent --remote-name https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_${ARCH}.zip
sudo apt-get install -y unzip
unzip nomad_${NOMAD_VERSION}_linux_${ARCH}.zip

# Nomad prepare binary #
########################
sudo mv nomad /usr/bin/
nomad --autocomplete-install
sudo mkdir --parents /opt/nomad
sudo mkdir --parents /etc/nomad.d
sudo useradd --system --home /etc/nomad.d --shell /bin/false nomad
sudo touch /etc/systemd/system/nomad.service

cat <<-EOF | sudo tee /etc/systemd/system/nomad.service
[Unit]
Description=Nomad
Documentation=https://www.nomadproject.io/docs/
Wants=network-online.target
After=network-online.target

# When using Nomad with Consul it is not necessary to start Consul first. These
# lines start Consul before Nomad as an optimization to avoid Nomad logging
# that Consul is unavailable at startup.
#Wants=consul.service
#After=consul.service

[Service]
User=nomad
Group=nomad
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/bin/nomad agent -config /etc/nomad.d
KillMode=process
KillSignal=SIGINT
LimitNOFILE=65536
LimitNPROC=infinity
Restart=on-failure
RestartSec=2

## Configure unit start rate limiting. Units which are started more than
## *burst* times within an *interval* time span are not permitted to start any
## more. Use `StartLimitIntervalSec` or `StartLimitInterval` (depending on
## systemd version) to configure the checking interval and `StartLimitBurst`
## to configure how many starts per interval are allowed. The values in the
## commented lines are defaults.

# StartLimitBurst = 5

## StartLimitIntervalSec is used for systemd versions >= 230
# StartLimitIntervalSec = 10s

## StartLimitInterval is used for systemd versions < 230
# StartLimitInterval = 10s

TasksMax=infinity
OOMScoreAdjust=-1000

[Install]
WantedBy=multi-user.target
EOF


cat <<-EOF  | sudo tee /etc/nomad.d/nomad.hcl
datacenter = "dc1"
data_dir = "/opt/nomad"

bind_addr = "192.168.56.72"

client {
  enabled = true
  servers = ["192.168.56.71"]
  server_join {
    retry_join = [ "192.168.56.71"]
  }
}
EOF
sudo chmod 700 /etc/nomad.d
sudo systemctl enable nomad
sudo systemctl start nomad
# install docker #
##################
sudo apt-get update
sudo apt-get install -y    ca-certificates     curl     gnupg  lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io


export NOMAD_ADDR=http://192.168.56.72:4646