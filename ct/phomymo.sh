#!/usr/bin/env bash
source /dev/stdin <<< "$FUNCTIONS_AS_SET"
color
verb_ip6
catch_errors
read_menu

function header_info {
clear
cat <<EOF
    ____  __                      __  ___      
   / __ \/ /_  ____  ____ ___  __ /  |/  /___ _
  / /_/ / __ \/ __ \/ __  __ \/ / /|_/ / __  /
 / ____/ / / / /_/ / / / / / / / /  / / /_/ / 
/_/   /_/ /_/\____/_/ /_/ /_/_/_/  /_/\__, /  
                                     /____/   
EOF
}

header_info
echo -e "\nSource: https://github.com/transcriptionstream/phomymo"

# Default LXC Settings
var_cpu="1"
var_ram="512"
var_disk="2"
var_os="debian"
var_version="13"
var_unprivileged="1"

# Build Logic
variables
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "Phomymo is available at: https://${IP}"