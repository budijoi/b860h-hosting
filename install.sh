#!/bin/bash

curl -fsSL \
https://raw.githubusercontent.com/budijoi/Script-Installer-Web-Hosting-B860H/refs/heads/main/sc-v1.sh \
-o /tmp/install-hosting.sh

chmod +x /tmp/install-hosting.sh

sudo /tmp/install-hosting.sh
