export FZF_COMPLETION_TRIGGER='\'
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
# zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# preview directory's content with eza when completing cd
# zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# zstyle ':fzf-tab:complete:ls:*' fzf-preview 'eza -1 --color=always $realpath'
# zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --line-range :500 $realpath || eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:*' fzf-preview '~/.config/zsh/fzf-preview.sh $realpath && bat $realpath --line-range :500 --color=always 2> /dev/null || eza -1 $realpath --color=always --icons'
zstyle ':fzf-tab:complete:vim:*' fzf-preview '~/.config/zsh/fzf-preview.sh $realpath && bat $realpath --line-range :500 --color=always 2> /dev/null || eza -1 $realpath --color=always --icons'
zstyle ':fzf-tab:complete:cd:*' fzf-preview '~/.config/zsh/fzf-preview.sh $realpath && bat $realpath --line-range :500 --color=always 2> /dev/null || eza -1 $realpath --color=always --icons'
zstyle ':fzf-tab:complete:ls:*' fzf-preview '~/.config/zsh/fzf-preview.sh $realpath && bat $realpath --line-range :500 --color=always 2> /dev/null || eza -1 $realpath --color=always --icons'
zstyle ':fzf-tab:complete:kitten:*' fzf-preview '~/.config/zsh/fzf-preview.sh $realpath'
# zstyle ':fzf-tab:complete:brew:*' fzf-preview 'bat --color=always <(brew info $word 2>/dev/null || brew search $word)'
# zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat $realpath --line-range :500 --color=always 2> /dev/null ||
#   eza -1 $realpath --color=always --icons'
# zstyle ':fzf-tab:complete:vim:*' fzf-preview 'bat --color=always --line-range :500 $realpath'
# zstyle ':fzf-tab:complete:ls:*' fzf-preview 'bat --color=always --line-range :300 $realpath'
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'
