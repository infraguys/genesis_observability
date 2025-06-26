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

PROMETHEUS_VERSION="3.4.1"

URL="https://github.com/prometheus/prometheus/releases/download/v$PROMETHEUS_VERSION/prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz"

curl -LO "$URL"
tar -xzf prometheus-*.tar.gz
mv "prometheus-$PROMETHEUS_VERSION.linux-amd64" /opt/prometheus
ln -sf /opt/prometheus/prometheus /usr/local/bin/prometheus
ln -sf /opt/prometheus/promtool /usr/local/bin/promtool

mkdir /prometheus
mkdir /etc/prometheus

useradd --no-create-home --shell /bin/false prometheus
chown -R prometheus:prometheus /opt/prometheus
chown prometheus:prometheus /prometheus

cp /usr/share/genesis_observability/prometheus/prometheus.service /etc/systemd/system/prometheus.service
cp /usr/share/genesis_observability/prometheus/prometheus.yml /etc/prometheus/prometheus.yml

systemctl daemon-reexec
systemctl daemon-reload
systemctl enable --now prometheus

# ✅ Prometheus has been installed and started as a system service.
#
# 👉 Next steps for proper configuration and management:
#
# 1. Review and customize the config at: /etc/prometheus/prometheus.yml
#    - Add more scrape jobs, alerting rules, remote write, etc.
#    - https://prometheus.io/docs/prometheus/latest/configuration/configuration/
#
# 2. Secure access:
#    - Run behind a reverse proxy (e.g., Nginx) for HTTPS/auth
#    - Or use experimantal basic authentication and TLS
#    - https://prometheus.io/docs/prometheus/latest/configuration/https/
#
# 3. Monitor Prometheus itself:
#    - It exposes metrics at http://localhost:9090/metrics
#
# 4. Add exporters (e.g., Node Exporter) to monitor system metrics.
#
