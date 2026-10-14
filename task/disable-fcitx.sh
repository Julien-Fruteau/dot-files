#!/usr/bin/env bash
set -eu

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
service_file="$config_dir/systemd/user/omarchy-fcitx5.service"
autostart_file="$config_dir/autostart/org.fcitx.Fcitx5.desktop"

mkdir -p "$(dirname "$service_file")" "$(dirname "$autostart_file")"

# Preserve an existing user override before replacing it.
if { [ -e "$service_file" ] || [ -L "$service_file" ]; } &&
   [ "$(readlink "$service_file" || true)" != /dev/null ]; then
  mv "$service_file" "$service_file.bak.$(date +%s).$$"
fi
if [ ! -L "$service_file" ]; then
  ln -s /dev/null "$service_file"
fi

if [ -f "$autostart_file" ] && ! grep -qx 'Hidden=true' "$autostart_file"; then
  cp -p "$autostart_file" "$autostart_file.bak.$(date +%s).$$"
fi
printf '[Desktop Entry]\nHidden=true\n' > "$autostart_file"

if systemctl --user daemon-reload && systemctl --user stop omarchy-fcitx5.service; then
  # Also stop an instance launched outside the Omarchy service.
  if command -v fcitx5-remote >/dev/null 2>&1; then
    fcitx5-remote -e || true
  fi
  echo "✅ Fcitx disabled"
else
  echo "Fcitx disabled for future sessions; log out and back in to apply."
fi
