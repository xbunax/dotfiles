# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
#
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi
# ZSH_THEME="powerlevel10k/powerlevel10k"
#
# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="robbyrussell"
# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git autojump vi-mode zsh-autosuggestions fzf-tab)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
# export http_proxy=127.0.0.1:7890;export https_proxy=$http_proxy

# export http_proxy="http://127.0.0.1:7890"
# export https_proxy="http://127.0.0.1:7890"

# startup
# eval tmux #start tmux
# $(which tmux)

export FZF_COMPLETION_TRIGGER='\'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
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
zstyle ':fzf-tab:complete:*' fzf-preview '/Users/xbunax/.oh-my-zsh/custom/plugins/fzf-tab/fzf-preview.sh $realpath && bat $realpath --line-range :500 --color=always 2> /dev/null || eza -1 $realpath --color=always --icons'
zstyle ':fzf-tab:complete:vim:*' fzf-preview '/Users/xbunax/.oh-my-zsh/custom/plugins/fzf-tab/fzf-preview.sh $realpath && bat $realpath --line-range :500 --color=always 2> /dev/null || eza -1 $realpath --color=always --icons'
zstyle ':fzf-tab:complete:cd:*' fzf-preview '/Users/xbunax/.oh-my-zsh/custom/plugins/fzf-tab/fzf-preview.sh $realpath && bat $realpath --line-range :500 --color=always 2> /dev/null || eza -1 $realpath --color=always --icons'
zstyle ':fzf-tab:complete:ls:*' fzf-preview '/Users/xbunax/.oh-my-zsh/custom/plugins/fzf-tab/fzf-preview.sh $realpath && bat $realpath --line-range :500 --color=always 2> /dev/null || eza -1 $realpath --color=always --icons'
zstyle ':fzf-tab:complete:kitten:*' fzf-preview '/Users/xbunax/.oh-my-zsh/custom/plugins/fzf-tab/fzf-preview.sh $realpath'
# zstyle ':fzf-tab:complete:brew:*' fzf-preview 'bat --color=always <(brew info $word 2>/dev/null || brew search $word)'
# zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat $realpath --line-range :500 --color=always 2> /dev/null ||
#   eza -1 $realpath --color=always --icons'
# zstyle ':fzf-tab:complete:vim:*' fzf-preview 'bat --color=always --line-range :500 $realpath'
# zstyle ':fzf-tab:complete:ls:*' fzf-preview 'bat --color=always --line-range :300 $realpath'
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'
export DBUS_SESSION_BUS_ADDRESS="unix:path=$DBUS_LAUNCHD_SESSION_BUS_SOCKET"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

#### alias

alias icat="kitten icat"
alias vim="nvim"
alias vzf='vim $(fzf)'
alias cc='clear'
alias openword='open -a /Applications/Microsoft\ Word.app'
alias stj='ssh mozhu@10.30.13.120'
alias vmcreate="orb create -a"
alias vmstart="orb -m"
alias vmstop="orb stop"
alias xvim="arch -x86_64 nvim"
alias ya="yazi"
alias lg=lazygit
alias gcc=gcc-14
alias lvim="lnvim"
alias nnvim="noplug_nvim"
alias vide="lvide"
alias leet="vim leetcode.nvim"
alias chrome="Google\ Chrome"

## environment

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
# export LDFLAGS="-L/opt/homebrew/opt/ncurses/lib"
# export CPPFLAGS="-I/opt/homebrew/opt/ncurses/include"
export _ZO_ECHO=1
export MTL_HUD_ENABLE=1
# export MPLBACKEND='module://matplotlib-backend-kitty'
export HELIX_RUNTIME=~/src/helix/runtime
export LIBTOOL=$(which glibtool)
export LIBTOOLIZE=$(which glibtoolize)
export LDFLAGS="-L/opt/homebrew/lib"
export CPPFLAGS="-I/opt/homebrew/include"
# export XDG_DATA_HOME="~/Library/Application Support"
# ln -s `which glibtoolize` /usr/local/bin/libtoolize
# ln -s /opt/homebrew/lib/lib/libncursesw.6.dylib /usr/local/lib/libncursesw.dylib

function sync_nvim() {
  local server=$1
  rsync -av --progress --delete ~/.config/nvim/ $server:~/.config/nvim/
  rsync -av --progress --delete ~/.local/share/nvim/lazy/ $server:~/.local/share/nvim/lazy/
}

function ya() {
  tmp="$(mktemp -t "yazi-cwd.XXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd -- "$cwd"
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
  get_wifi_name=$(networksetup -getairportnetwork en0 | awk -F': ' '{print $2}')
  wifi_name=("TJ-WIFI" "Redmi_6D59_5G" "TJ-DORM-WIFI" "Redmi_5634_5G")
  if [ "$get_wifi_name" = "${wifi_name[1]}" ]; then
    proxy_ip=100.79.118.216
  elif [ "$get_wifi_name" = "${wifi_name[2]}" ]; then
    proxy_ip=192.168.31.26
  elif [ "$get_wifi_name" = "${wifi_name[3]}" ]; then
    proxy_ip=100.72.95.21
  elif [ "$get_wifi_name" = "${wifi_name[4]}" ]; then
    proxy_ip=192.168.31.26
  fi
  proxy_ip=127.0.0.1
  export https_proxy=http://$proxy_ip:7891 http_proxy=http://$proxy_ip:7891 all_proxy=socks5://$proxy_ip:7891
}
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2>/dev/null)"
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

# export PKG_CONFIG_PATH="/opt/homebrew/opt/opencv@2/lib/pkgconfig"
eval "$(starship init zsh)"
eval "$(fzf --zsh)"
eval "$(atuin init zsh)"
eval "$(zoxide init zsh)"
