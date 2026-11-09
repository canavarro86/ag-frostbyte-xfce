# Frostbyte modern tools. Выключить: touch ~/.config/frostbyte/no-tools
[ -f ~/.config/frostbyte/no-tools ] && return
if command -v eza >/dev/null; then
  alias ls='eza -lah --group-directories-first --git --time-style=long-iso'
  alias lt='eza --tree --level=2 --group-directories-first'
fi
if command -v batcat >/dev/null; then
  alias bat='batcat'; alias cat='batcat --paging=never --style=plain'; export BAT_THEME=ansi
fi
if command -v fzf >/dev/null; then
  eval "$(fzf --bash 2>/dev/null)" || { [ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && . /usr/share/doc/fzf/examples/key-bindings.bash; }
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border=rounded --color=bg+:#1a2436,fg+:#e8f0fb,hl:#5b8ff0,hl+:#82abff,pointer:#38bdd6,prompt:#5b8ff0,info:#8a97aa,border:#3a4a63'
fi
command -v zoxide >/dev/null && eval "$(zoxide init bash --cmd cd)"
