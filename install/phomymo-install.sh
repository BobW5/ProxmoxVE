#!/usr/bin/env bash

# Copyright (c) 2021-2026 tteck
# Author: YourName (Community Contribution)
# License: MIT
# https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE

source /dev/stdin <<< "$FUNCTIONS_AS_SET"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y curl sudo mc git python3 nginx openssl
msg_ok "Installed Dependencies"

msg_info "Cloning Phomymo"
$STD git clone https://github.com/transcriptionstream/phomymo /opt/phomymo
msg_ok "Cloned Phomymo"

msg_info "Configuring SSL (Self-Signed)"
$STD openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/phomymo.key \
  -out /etc/ssl/certs/phomymo.crt \
  -subj "/C=US/ST=Home/L=Lab/O=Proxmox/CN=phomymo.local"
msg_ok "Configured SSL"

msg_info "Creating Phomymo Service"
cat <<EOF >/etc/systemd/system/phomymo.service
[Unit]
Description=Phomymo Static Web Server
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/phomymo/src/web
ExecStart=/usr/bin/python3 -m http.server 8080 --bind 127.0.0.1
Restart=always

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now phomymo
msg_ok "Created Phomymo Service"

msg_info "Configuring Nginx Proxy"
cat <<EOF >/etc/nginx/sites-available/phomymo
server {
    listen 443 ssl;
    server_name _;
    ssl_certificate /etc/ssl/certs/phomymo.crt;
    ssl_certificate_key /etc/ssl/private/phomymo.key;
    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF
ln -s /etc/nginx/sites-available/phomymo /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
systemctl restart nginx
msg_ok "Configured Nginx Proxy"

motd_ssh
customize