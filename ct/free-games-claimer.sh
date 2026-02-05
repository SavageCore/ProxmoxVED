#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVED/main/misc/build.func)
# Copyright (c) 2021-2026 community-scripts ORG
# Author: SavageCore
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/vogler/free-games-claimer

APP="free-games-claimer"
var_tags="${var_tags:-automation;gaming}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-512}"
var_disk="${var_disk:-4}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  if [[ ! -d /opt/free-games-claimer ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  if check_for_gh_release "free-games-claimer" "vogler/free-games-claimer"; then
    msg_info "Stopping Services"
    systemctl stop free-games-claimer
    systemctl stop free-games-claimer-vnc
    msg_ok "Stopped Services"

    msg_info "Backing up Data"
    cp -r /opt/free-games-claimer/data /opt/free-games-claimer_data_backup
    msg_ok "Backed up Data"

    CLEAN_INSTALL=1 fetch_and_deploy_gh_release "free-games-claimer" "vogler/free-games-claimer" "tarball"

    cd /opt/free-games-claimer || exit
    $STD npm install
    $STD npx patchright install chromium --no-shell

    msg_info "Restoring Data"
    cp -r /opt/free-games-claimer_data_backup/. /opt/free-games-claimer/data
    rm -rf /opt/free-games-claimer_data_backup
    msg_ok "Restored Data"

    msg_info "Starting Services"
    systemctl start free-games-claimer-vnc
    msg_ok "Started Services"
    msg_ok "Updated successfully!"
  fi
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:6080${CL}"
