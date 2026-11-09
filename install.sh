#!/usr/bin/env bash
# Frostbyte 1.0 — installs the author's XFCE desktop for the current user
# ./install.sh [night|void|solar|light]   (no argument = exactly as the author's)
set -e
SRC=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd); S=$SRC/extras/snapshot
DEST=$HOME/.local/share/frostbyte; B=$HOME/.local/share/frostbyte-backup
X=$HOME/.config/xfce4/xfconf/xfce-perchannel-xml
[ -d "$S/xml" ] || { echo "Нет снимка. Запускайте из папки темы."; exit 1; }
[ "$SRC" = "$DEST" ] && { echo "Запускайте из скачанной папки, а не из $DEST"; exit 1; }
[ "${XDG_CURRENT_DESKTOP:-}" = XFCE ] || echo "Внимание: текущий рабочий стол не XFCE"

echo "==> зависимости"
NEED=(plank conky-all fonts-jetbrains-mono fonts-inter xfce4-terminal x11-utils xdotool curl iw dconf-cli git eza bat fzf zoxide btop libnotify-bin xz-utils)
mapfile -t EXTRA < "$S/packages.txt"
MISS=(); for p in "${NEED[@]}" "${EXTRA[@]}"; do [ -n "$p" ] && ! dpkg -s "$p" >/dev/null 2>&1 && MISS+=("$p"); done
if [ ${#MISS[@]} -gt 0 ]; then echo "    ставлю: ${MISS[*]}"; sudo apt-get update -qq; sudo apt-get install -y "${MISS[@]}"
else echo "    всё установлено"; fi

echo "==> резервная копия"
if [ ! -d "$B" ]; then
  mkdir -p "$B/xml"
  for c in xfce4-panel xfwm4 xsettings xfce4-terminal xfce4-desktop; do cp "$X/$c.xml" "$B/xml/" 2>/dev/null || true; done
  [ -d ~/.config/xfce4/panel ] && cp -a ~/.config/xfce4/panel "$B/panel"
  [ -d ~/.config/plank ] && cp -a ~/.config/plank "$B/plank"
  dconf dump /net/launchpad/plank/ > "$B/plank.dconf" 2>/dev/null || true
  cp ~/.bashrc "$B/bashrc"; : > "$B/vendor.txt"
  echo "    $B"
else echo "    уже есть $B — не перезаписываю"; fi

echo "==> файлы темы"
rm -rf "$DEST"; mkdir -p "$DEST"; cp -a "$SRC"/. "$DEST"/; rm -rf "$DEST/.git"
mkdir -p ~/.themes ~/.local/bin ~/.config/autostart ~/.local/share/plank/themes ~/.local/share/xfce4/terminal/colorschemes
rm -rf ~/.themes/Frostbyte; mkdir ~/.themes/Frostbyte
cp -a "$SRC/index.theme" "$SRC/gtk-3.0" "$SRC/xfwm4" ~/.themes/Frostbyte/
for t in "$S"/vendor/themes/*; do n=$(basename "$t"); [ -e ~/.themes/$n ] || { cp -a "$t" ~/.themes/; echo "theme:$n" >> "$B/vendor.txt"; }; done
if [ ! -d ~/.local/share/icons/WhiteSur ]; then
  T=$(mktemp -d); git clone --depth=1 https://github.com/vinceliuice/WhiteSur-icon-theme.git "$T/i" && "$T/i/install.sh"; rm -rf "$T"
  echo "icons:WhiteSur" >> "$B/vendor.txt"
fi
ln -sfn "$DEST/extras/plank/Frostbyte" ~/.local/share/plank/themes/Frostbyte
cp "$DEST"/extras/terminal/*.theme ~/.local/share/xfce4/terminal/colorschemes/
chmod +x "$DEST"/*.sh "$DEST"/extras/bin/* "$DEST"/extras/terminal/apply.sh
for b in frostfetch frostbyte-layers frostbyte-net frostbyte-conky; do ln -sf "$DEST/extras/bin/$b" ~/.local/bin/$b; done

echo "==> рабочий стол"
pkill -x plank || true; pkill -x xfce4-panel || true; pkill -u "$USER" -x xfconfd || true; sleep 1
mkdir -p "$X"
for f in "$S"/xml/*.xml; do sed "s|@HOME@|$HOME|g" "$f" > "$X/$(basename "$f")"; done
rm -rf ~/.config/xfce4/panel; cp -a "$S/panel" ~/.config/xfce4/panel
grep -rl @HOME@ ~/.config/xfce4/panel | xargs -r sed -i "s|@HOME@|$HOME|g"
mkdir -p ~/.config/plank/dock1; rm -rf ~/.config/plank/dock1/launchers
[ -d "$S/plank-launchers" ] && cp -a "$S/plank-launchers" ~/.config/plank/dock1/launchers
dconf load /net/launchpad/plank/ < "$S/plank.dconf"
setsid xfsettingsd --replace >/dev/null 2>&1 &
setsid xfwm4 --replace >/dev/null 2>&1 &
setsid xfce4-panel >/dev/null 2>&1 &
sleep 2
W=$(ls "$DEST"/extras/snapshot/wallpaper.* 2>/dev/null | head -1)
[ -n "$W" ] && for p in $(xfconf-query -c xfce4-desktop -l | grep last-image); do xfconf-query -c xfce4-desktop -p "$p" -s "$W"; done
case ${1:-} in night|void|solar) "$DEST/extras/terminal/apply.sh" "frostbyte-$1";; light) "$DEST/extras/terminal/apply.sh" frostbyte;; esac

for p in ~/.mozilla/firefox/*.default*/ ~/.config/mozilla/firefox/*.default*/ ~/.thunderbird/*.default*/ ~/.config/thunderbird/*.default*/; do
  [ -d "$p" ] || continue
  grep -q non-native-titlebar "$p/user.js" 2>/dev/null || cat "$DEST/extras/firefox/user.js" >> "$p/user.js"; mkdir -p "$p/chrome"; cp "$DEST/extras/firefox/userChrome.css" "$p/chrome/"
done

sed -i '/# >>> frostbyte >>>/,/# <<< frostbyte <<</d' ~/.bashrc
cat >> ~/.bashrc <<RC
# >>> frostbyte >>>
export PATH="\$HOME/.local/bin:\$PATH"
[ -f "$DEST/extras/bash/frostbyte-prompt.sh" ] && . "$DEST/extras/bash/frostbyte-prompt.sh"
# <<< frostbyte <<<
RC

auto() { printf '[Desktop Entry]\nType=Application\nName=%s\nExec=sh -c '"'"'sleep %s; exec %s'"'"'\nX-GNOME-Autostart-enabled=true\n' "$2" "$3" "$4" > ~/.config/autostart/$1.desktop; }
auto frostbyte-conky  "Frostbyte Conky"  3 "$HOME/.local/bin/frostbyte-conky"
auto frostbyte-layers "Frostbyte Layers" 2 "$HOME/.local/bin/frostbyte-layers"
auto frostbyte-plank  "Frostbyte Dock"   2 "plank"

echo "==> запуск"
pkill -f frostbyte-layers || true; pkill -u "$USER" -f 'xprop -spy -root' || true; pkill -u "$USER" -x conky || true
sleep 1
setsid ~/.local/bin/frostbyte-conky >/dev/null 2>&1 &
setsid ~/.local/bin/frostbyte-layers >/dev/null 2>&1 &
setsid plank >/dev/null 2>&1 &
echo; echo "Frostbyte установлен. Для полного применения перезайдите в сеанс."
echo "Удаление: $DEST/uninstall.sh"
