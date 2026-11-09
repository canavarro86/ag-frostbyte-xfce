#!/bin/bash
# Frostbyte addons: btop theme, Bibata cursor, notifications. ./addons.sh install|remove
D=$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)
xs() { xfconf-query -c "$1" -p "$2" -s "$3" 2>/dev/null || xfconf-query -c "$1" -p "$2" -n -t "${4:-string}" -s "$3"; }
C=~/.config/btop/btop.conf
case ${1:-install} in
install)
  mkdir -p ~/.config/btop/themes; cp "$D/extras/btop/frostbyte.theme" ~/.config/btop/themes/
  if [ -f $C ]; then sed -i 's|^color_theme = .*|color_theme = "frostbyte"|; s|^theme_background = .*|theme_background = False|' $C
  else printf 'color_theme = "frostbyte"\ntheme_background = False\n' > $C; fi
  if [ ! -d ~/.icons/Bibata-Modern-Ice ]; then
    mkdir -p ~/.icons
    curl -fsSL https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Ice.tar.xz | tar xJ -C ~/.icons
  fi
  xs xsettings /Gtk/CursorThemeName Bibata-Modern-Ice; xs xsettings /Gtk/CursorThemeSize 24 int
  mkdir -p ~/.icons/default; printf '[Icon Theme]\nInherits=Bibata-Modern-Ice\n' > ~/.icons/default/index.theme
  mkdir -p ~/.themes/Frostbyte; cp -r "$D/xfce-notify-4.0" ~/.themes/Frostbyte/
  xs xfce4-notifyd /theme Frostbyte; xs xfce4-notifyd /initial-opacity 1.0 double
  echo "addons: OK" ;;
remove)
  rm -f ~/.config/btop/themes/frostbyte.theme
  [ -f $C ] && sed -i 's|^color_theme = "frostbyte"|color_theme = "Default"|' $C
  xs xsettings /Gtk/CursorThemeName Adwaita
  grep -qs Bibata ~/.icons/default/index.theme && rm -f ~/.icons/default/index.theme
  rm -rf ~/.icons/Bibata-Modern-Ice ~/.themes/Frostbyte/xfce-notify-4.0
  xs xfce4-notifyd /theme Default
  echo "addons: removed" ;;
esac
