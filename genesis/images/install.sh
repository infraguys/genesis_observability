#!/usr/bin/env bash

# Copyright 2025 Genesis Corporation
#
# All Rights Reserved.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

set -eu
set -x
set -o pipefail

[[ "$EUID" == 0 ]] || exec sudo -s "$0" "$@"

GRAFANA_VERSION="12.0.2"
LOKI_VERSION="3.4.4"

WORK_DIR="/tmp"
SHARE_DIR="/usr/share/genesis_observability"
PROMTAIL_CONFIG_DIR="/etc/promtail"
GRAFANA_CONFIG_DIR="/etc/grafana"


cd "$WORK_DIR"

# install Grafana
apt install -y adduser libfontconfig1 musl

# install Loki
wget https://github.com/grafana/loki/releases/download/v"$LOKI_VERSION"/loki_"$LOKI_VERSION"_amd64.deb
wget https://github.com/grafana/loki/releases/download/v"$LOKI_VERSION"/promtail_"$LOKI_VERSION"_amd64.deb
dpkg -i loki_"$LOKI_VERSION"_amd64.deb
dpkg -i promtail_"$LOKI_VERSION"_amd64.deb

usermod -aG adm promtail
cp "$SHARE_DIR/promtail/config.yml" "$PROMTAIL_CONFIG_DIR/config.yml"

systemctl enable loki
systemctl enable promtail


wget https://dl.grafana.com/oss/release/grafana_"$GRAFANA_VERSION"_amd64.deb
dpkg -i grafana_"$GRAFANA_VERSION"_amd64.deb

mkdir -p "$GRAFANA_CONFIG_DIR/provisioning/datasources/"
cp "$SHARE_DIR/grafana/provisioning/datasources/loki-datasource.yaml" "$GRAFANA_CONFIG_DIR/provisioning/datasources/loki-datasource.yaml"

# Enable grafana
systemctl enable grafana-server
