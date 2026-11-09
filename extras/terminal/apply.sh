#!/bin/bash
set -e
SCHEME=${1:-frostbyte-night}
DIR=$(cd "$(dirname "$0")" && pwd)
mkdir -p ~/.local/share/xfce4/terminal/colorschemes
cp "$DIR"/*.theme ~/.local/share/xfce4/terminal/colorschemes/
SET=(
"FontName=JetBrains Mono 12"
FontUseSystem=FALSE
BackgroundMode=TERMINAL_BACKGROUND_SOLID
BackgroundDarkness=0.95
MiscMenubarDefault=FALSE
ScrollingBar=TERMINAL_SCROLLBAR_NONE
MiscCursorShape=TERMINAL_CURSOR_SHAPE_IBEAM
MiscCursorBlinks=TRUE
)
while IFS= read -r l; do [[ $l == Color* || $l == TabActivityColor* ]] && SET+=("$l"); done < "$DIR/$SCHEME.theme"
v=$(xfce4-terminal --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
if dpkg --compare-versions "$v" ge 1.1.0; then
  for kv in "${SET[@]}"; do
    k=${kv%%=*}; val=${kv#*=}
    p=/$(sed -E 's/([a-z0-9])([A-Z])/\1-\2/g' <<<"$k" | tr A-Z a-z)
    case $val in TRUE|FALSE) t=bool; val=${val,,};; [0-9].[0-9]*) t=double;; *) t=string;; esac
    xfconf-query -c xfce4-terminal -p "$p" -n -t $t -s "$val" 2>/dev/null || xfconf-query -c xfce4-terminal -p "$p" -s "$val"
  done
else
  RC=~/.config/xfce4/terminal/terminalrc
  mkdir -p "${RC%/*}"; [ -f "$RC" ] || echo '[Configuration]' > "$RC"
  for kv in "${SET[@]}"; do k=${kv%%=*}
    grep -q "^$k=" "$RC" && sed -i "s|^$k=.*|$kv|" "$RC" || echo "$kv" >> "$RC"
  done
fi
echo "terminal: OK"
