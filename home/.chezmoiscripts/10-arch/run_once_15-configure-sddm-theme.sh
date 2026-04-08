#!/usr/bin/env zsh

# Configure SDDM to use where-is-my-sddm-theme (minimal login screen)
sudo mkdir -p /etc/sddm.conf.d
sudo tee /etc/sddm.conf.d/theme.conf > /dev/null <<'EOF'
[Theme]
Current=sugar-candy
EOF
