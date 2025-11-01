#!/bin/bash


# https://github.com/prometheus/node_exporter/releases
VERSION="1.9.1"


cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v$VERSION/node_exporter-$VERSION.linux-amd64.tar.gz
tar xvfz node_exporter-$VERSION.linux-amd64.tar.gz
cd node_exporter-$VERSION.linux-amd64

mv node_exporter /usr/local/bin/
rm -rf /tmp/node_exporter*

useradd -r -s /bin/false node_exporter
chown node_exporter:node_exporter /usr/local/bin/node_exporter


cat <<EOF> /etc/systemd/system/node_exporter.service
[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
Type=simple
User=node_exporter
Group=node_exporter
ExecStart=/usr/local/bin/node_exporter
Restart=on-failure

ProtectSystem=full
ProtectHome=read-only
PrivateTmp=yes
NoNewPrivileges=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start node_exporter
systemctl enable node_exporter
systemctl status node_exporter

node_exporter --version

rm ./node-exporter-ub.sh
