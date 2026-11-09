# Frostbyte prompt
__fb_prompt() {
  local e=$? b
  b=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
  b=${b//\\/\\\\}; b=${b//\$/\\\$}; b=${b//\`/\\\`}
  local s='\[\e[1;97;44m\] \u \[\e[0;30;46m\] \w '
  [ -n "$b" ] && s+='\[\e[0;97;45m\] ⎇ '"$b"' '
  (exec 3<>/dev/tcp/127.0.0.1/1090) 2>/dev/null && s+='\[\e[0;30;42m\] ⇅ socks '
  s+='\[\e[0m\]\n'
  [ $e -eq 0 ] && s+='\[\e[1;34m\]❯\[\e[0m\] ' || s+='\[\e[1;31m\]❯\[\e[0m\] '
  PS1=$s
}
PROMPT_COMMAND=__fb_prompt
[ -f "${BASH_SOURCE%/*}/frostbyte-tools.sh" ] && . "${BASH_SOURCE%/*}/frostbyte-tools.sh"
