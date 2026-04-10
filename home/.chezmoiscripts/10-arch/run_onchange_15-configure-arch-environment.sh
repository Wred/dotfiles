#!/usr/bin/env zsh

# Create standard XDG user directories (Documents, Downloads, etc.)
xdg-user-dirs-update

# Configure SDDM to use sugar-candy theme
sudo mkdir -p /etc/sddm.conf.d
sudo tee /etc/sddm.conf.d/theme.conf > /dev/null <<'EOF'
[Theme]
Current=sugar-candy
EOF

# Configure sugar-candy theme
sudo tee /usr/share/sddm/themes/sugar-candy/theme.conf.user > /dev/null <<'EOF'
[General]
FormPosition=center
Background="background.jpg"
AccentColor="white"
EOF
