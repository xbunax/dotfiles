### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
  print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
  command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
  command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" &&
    print -P "%F{33} %F{34}Installation successful.%f%b" ||
    print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

export FZF_COMPLETION_TRIGGER='\'
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# disable sort when completing `git checkout`
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

if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

  autoload -Uz compinit
  compinit
fi

#### alias
alias icat="kitten icat"
alias vim="nvim"
alias vzf='lvim $(fzf)'
alias openword='open -a /Applications/Microsoft\ Word.app'
alias vmcreate="orb create -a"
alias vmstart="orb -m"
alias vmstop="orb stop"
alias stj='ssh mozhu@10.30.13.120'
# alias ya="yazi"
alias lg=lazygit
alias gcc=gcc-14
alias lvim="lnvim"
alias nnvim="noplug_nvim"
alias vide="lvide"
alias c="clear"
alias leet="vim leetcode.nvim"
alias chrome="Google\ Chrome"
alias avim="NVIM_APPNAME=astronvim nvim"
alias z="zoxide"

#### environment

export PATH="/usr/local/opt/openjdk/bin:$PATH"
# export PATH="$HOME/.local/bin:$PATH"
export PATH=/usr/local/bin:/usr/local/opt/openjdk/bin:/usr/local/opt/openjdk/bin:/usr/local/opt/openjdk/bin:/usr/local/opt/openjdk/bin:/Users/xbunax/anaconda3/bin:/Users/xbunax/anaconda3/condabin:/usr/local/opt/openjdk/bin:/usr/local/bin:/usr/local/sbin:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/opt/X11/bin:/Library/Apple/usr/bin:/Library/TeX/texbin:/Users/xbunax/.cargo/bin:/usr/local/bin:/Users/xbunax/.local/bin:
export PATH="/Users/xbunax/Documents/Document/typst/bin/:$PATH"
export PATH="/usr/local/opt/qt/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH="/Applications/Google Chrome.app/Contents/MacOS:$PATH"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/opt/homebrew/Cellar/mpv/0.37.0_1/lib/pkgconfig"
export DISABLE_AUTO_TITLE='true'
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/opt/homebrew/opt/ncurses/lib/pkgconfig"
export _ZO_ECHO=1
export MTL_HUD_ENABLE=1
export HELIX_RUNTIME=~/src/helix/runtime
export LDFLAGS="-L/opt/homebrew/lib"
export CPPFLAGS="-I/opt/homebrew/include"
export LIBTOOL=$(which glibtool)
export LIBTOOLIZE=$(which glibtoolize)
export EDITOR=lnvim
# ln -s $(which glibtoolize) /usr/local/bin/libtoolize

function sync_nvim() {
  local server=$1
  rsync -av --progress --delete ~/.config/nvim/ $server:~/.config/nvim/
  rsync -av --progress --delete ~/.local/share/nvim/lazy/ $server:~/.local/share/nvim/lazy/
}

function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

function lnvim() {
  XDG_CONFIG_HOME=~/.config/lazyvim/ nvim "$@"
}

function noplug_nvim() {
  XDG_CONFIG_HOME=~/.config/nvim_no_plug/ nvim "$@"
}

function lvide() {
  XDG_CONFIG_HOME=~/.config/lazyvim/ neovide "$@"
}

function set_proxy() {
  proxy_ip=$1
  port=$2
  export https_proxy=http://$proxy_ip:$port http_proxy=http://$proxy_ip:$port all_proxy=socks5://$proxy_ip:$port
}

set_proxy 127.0.0.1 7897
zinit ice depth=1
zinit light jeffreytse/zsh-vi-mode
zinit load atuinsh/atuin
zinit light Aloxaf/fzf-tab
zinit light zsh-users/zsh-syntax-highlighting


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"


