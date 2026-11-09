#!/bin/bash
set -e
D=$(cd "$(dirname "$0")" && pwd)/xfwm4; H=36; cd "$D"
LINE='#dfe6ef'
for s in active inactive; do
  [ $s = active ] && BG='#f6f9fd' || BG='#eef3f9'
  for i in 1 2 3 4 5; do
    convert -size 1x$H xc:$BG -fill $LINE -draw "point 0,$((H-1))" title-$i-$s.png
  done
  convert -size 12x$H xc:none -fill $BG -draw "roundrectangle 0,0 23,$((H+12)) 10,10" top-left-$s.png
  convert -size 12x$H xc:none -fill $BG -draw "roundrectangle -12,0 11,$((H+12)) 10,10" top-right-$s.png
  for p in left right bottom bottom-left bottom-right; do convert -size 1x1 xc:$LINE $p-$s.png; done
done
btn() { n=$1; c=$2; cp=$3; g=$4
  for s in active inactive prelight pressed; do
    BG='#f6f9fd'; fc=$c
    [ $s = inactive ] && { BG='#eef3f9'; fc='#c8d2df'; }
    [ $s = pressed ] && fc=$cp
    a=(-size 22x$H xc:$BG -fill "$fc" -stroke none -draw "circle 11,18 11,11.5")
    [[ $s = prelight || $s = pressed ]] && a+=(-fill none -stroke '#3b2a22' -strokewidth 1.4 -draw "$g")
    convert "${a[@]}" $n-$s.png
  done
}
btn close    '#ff5f57' '#d9443d' 'line 8.5,15.5 13.5,20.5 line 13.5,15.5 8.5,20.5'
btn hide     '#febc2e' '#d99a18' 'line 8,18 14,18'
btn maximize '#28c840' '#1ea534' 'line 11,15 11,21 line 8,18 14,18'
for s in active inactive prelight pressed; do cp maximize-$s.png maximize-toggled-$s.png; done
echo OK
