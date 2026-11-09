#!/usr/bin/env bash
# Frostbyte: remove and restore previous desktop
B=$HOME/.local/share/frostbyte-backup; X=$HOME/.config/xfce4/xfconf/xfce-perchannel-xml
pkill -f frostbyte-layers; pkill -u "$USER" -f 'xprop -spy -root'; pkill -u "$USER" -x conky; pkill -x plank
for p in ~/.mozilla/firefox/*/user.js ~/.config/mozilla/firefox/*/user.js; do
  [ -f "$p" ] && sed -i '/non-native-titlebar-buttons\|browser.tabs.inTitlebar/d' "$p"
done
sed -i '/# >>> frostbyte >>>/,/# <<< frostbyte <<</d' ~/.bashrc
rm -f ~/.local/bin/frostfetch ~/.local/bin/frostbyte-{layers,net,conky} ~/.config/autostart/frostbyte-*.desktop \
      ~/.local/share/xfce4/terminal/colorschemes/frostbyte*.theme /tmp/frostbyte-conky.$UID.conf
rm -rf ~/.themes/Frostbyte ~/.local/share/plank/themes/Frostbyte
if [ -d "$B" ]; then
  while IFS=: read -r k n; do
    case $k in theme) rm -rf ~/.themes/"$n";; icons) rm -rf ~/.local/share/icons/WhiteSur*;; esac
  done < "$B/vendor.txt"
  pkill -x xfce4-panel; pkill -u "$USER" -x xfconfd; sleep 1
  rm -f "$X"/{xfce4-panel,xfwm4,xsettings,xfce4-terminal}.xml
  cp "$B"/xml/*.xml "$X/" 2>/dev/null
  rm -rf ~/.config/xfce4/panel; [ -d "$B/panel" ] && cp -a "$B/panel" ~/.config/xfce4/panel
  rm -rf ~/.config/plank; [ -d "$B/plank" ] && cp -a "$B/plank" ~/.config/plank
  dconf reset -f /net/launchpad/plank/; [ -s "$B/plank.dconf" ] && dconf load /net/launchpad/plank/ < "$B/plank.dconf"
  setsid xfsettingsd --replace >/dev/null 2>&1 &
  setsid xfwm4 --replace >/dev/null 2>&1 &
  setsid xfce4-panel >/dev/null 2>&1 &
  mv "$B" "$B.restored-$(date +%F-%H%M)"
  echo "Прежние настройки восстановлены."
fi
"$HOME/.local/share/frostbyte/extras/addons.sh" remove
rm -rf "$HOME/.local/share/frostbyte"
echo "Frostbyte удалён. Перезайдите в сеанс."
