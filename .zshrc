### Added by Zinit's installer
# if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
#   print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
#   command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
#   command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" &&
#     print -P "%F{33} %F{34}Installation successful.%f%b" ||
#     print -P "%F{160} The clone has failed.%f%b"
# fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

source ~/.config/zsh/fzf-tab.zsh
source ~/.config/zsh/brew.zsh
source ~/.config/zsh/fastanime.zsh

#### alias
alias ft="fastfetch --kitty-icat ~/.config/fastfetch/archpuccinn.png"
alias icat="kitten icat"
alias vzf='lvim $(fzf)'
alias openword='open -a /Applications/Microsoft\ Word.app'
alias vmcreate="orb create -a"
alias vmstart="orb -m"
alias vmstop="orb stop"
alias stj='ssh mozhu@10.30.13.120'
alias lg=lazygit
alias git=/opt/homebrew/bin/git
alias lvim="lnvim"
alias c="clear"
alias leet="vim leetcode.nvim"
alias avim="NVIM_APPNAME=astronvim nvim"

#### environment

export PATH="/usr/local/opt/openjdk/bin:$PATH"
# export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
export PATH="~/.local/bin:$PATH"
export PATH=/usr/local/bin:/usr/local/opt/openjdk/bin:/usr/local/opt/openjdk/bin:/usr/local/opt/openjdk/bin:/usr/local/opt/openjdk/bin:/Users/xbunax/anaconda3/bin:/Users/xbunax/anaconda3/condabin:/usr/local/opt/openjdk/bin:/usr/local/bin:/usr/local/sbin:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/opt/X11/bin:/Library/Apple/usr/bin:/Library/TeX/texbin:/Users/xbunax/.cargo/bin:/usr/local/bin:/Users/july/.local/bin:
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export DISABLE_AUTO_TITLE='true'
export _ZO_ECHO=1
export MTL_HUD_ENABLE=1
export HELIX_RUNTIME=~/src/helix/runtime
export LDFLAGS="-L/opt/homebrew/lib"
export CPPFLAGS="-I/opt/homebrew/include"
export LIBTOOL=$(which glibtool)
export LIBTOOLIZE=$(which glibtoolize)
export EDITOR=nvim
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
# __conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2>/dev/null)"
# if [ $? -eq 0 ]; then
#   eval "$__conda_setup"
# else
  if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
    . "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
  else
    export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
  fi
# fi
# unset __conda_setup
# <<< conda initialize <<<

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
