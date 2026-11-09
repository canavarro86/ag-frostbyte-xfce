#!/bin/bash
# Frostbyte: snapshot of the current desktop into the theme
R=$(cd "$(dirname "$0")" && pwd); S=$R/extras/snapshot
X=~/.config/xfce4/xfconf/xfce-perchannel-xml
rm -rf "$S"; mkdir -p "$S/xml" "$S/vendor/themes"
for c in xfce4-panel xfwm4 xsettings xfce4-terminal; do
  cp "$X/$c.xml" "$S/xml/"; sed -i "s|$HOME|@HOME@|g" "$S/xml/$c.xml"
done
cp -a ~/.config/xfce4/panel "$S/panel"; grep -rl "$HOME" "$S/panel" | xargs -r sed -i "s|$HOME|@HOME@|g"
dconf dump /net/launchpad/plank/ > "$S/plank.dconf"
[ -d ~/.config/plank/dock1/launchers ] && cp -a ~/.config/plank/dock1/launchers "$S/plank-launchers"
W=$(xfconf-query -c xfce4-desktop -l -v | awk '/last-image/{print $2; exit}')
[ -f "$W" ] && cp "$W" "$S/wallpaper.${W##*.}"
for p in $(grep -oP 'name="plugin-\d+" type="string" value="\K[^"]+' "$S/xml/xfce4-panel.xml" | sort -u); do
  f=$(ls /usr/lib/*/xfce4/panel/plugins/lib$p.so 2>/dev/null | head -1)
  [ -n "$f" ] && dpkg -S "$f" 2>/dev/null | cut -d: -f1
done | sort -u > "$S/packages.txt"
cp -a ~/.themes/WhiteSur-Light-blue "$S/vendor/themes/"
echo "snapshot: $S"; echo "плагины панели:"; cat "$S/packages.txt"; du -sh "$S"
