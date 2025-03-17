# ~/.config/fish/config.fish

# set -g fish_autosuggestion_enabled 0

set -x PTAH $HOME/bin /usr/local/bin $PATH
set -x PATH /opt/homebrew/bin $PATH
set -x PATH $HOME/.local/bin $PATH
set -x PATH $HOME/.cargo/bin $PATH
#set -x PATH /usr/local/bin /usr/local/opt/openjdk/bin /usr/local/opt/openjdk/bin /usr/local/opt/openjdk/bin /usr/local/opt/openjdk/bin /usr/local/opt/openjdk/bin /usr/local/bin /usr/local/sbin /opt/local/bin /opt/local/sbin /usr/local/bin /System/Cryptexes/App/usr/bin /usr/bin /bin /usr/sbin /sbin /var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin /var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin /var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin /opt/X11/bin /Library/Apple/usr/bin /Library/TeX/texbin /Users/july/.cargo/bin /usr/local/bin /Users/july/.local/bin $PATH

alias lg=lazygit
alias gcc=gcc-14
alias nnvim="noplug_nvim"
alias vide="lvide"
alias c="clear"
alias leet="vim leetcode.nvim"
alias stj="ssh mozhu@10.30.13.120"
alias ft="fastfetch --kitty-icat ~/.config/fastfetch/archpuccinn.png"

set -U EDITOR lvim

set -U OPENAI_API_KEY sk-e29f3b0c60bb4050a05b55c7abba88ac
set -U DEEPSEEK_API_KEY sk-e29f3b0c60bb4050a05b55c7abba88ac

set fzf_preview_dir_cmd eza --all --color=always
set fzf_fd_opts --hidden --max-depth 1
set fzf_preview_file_cmd bat --color=always

bind -M visual y fish_clipboard_copy
bind -M normal yy fish_clipboard_copy
bind p fish_clipboard_paste

fzf_configure_bindings --directory=\cf

function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

function lvim
    set -gx XDG_CONFIG_HOME ~/.config/lazyvim/
    nvim $argv
    # env XDG_CONFIG_HOME=~/.config/lazyvim/ nvim $argv
end

function fish_user_key_bindings
    fish_vi_key_bindings
end

function proxy
    set -Ux all_proxy http://127.0.0.1:7897
    set -Ux http_proxy http://127.0.0.1:7897
    set -Ux https_proxy http://127.0.0.1:7897
    #echo all_proxy=$all_proxy
    #echo http_proxy=$http_proxy
    #echo https_proxy=$https_proxy
end

function noproxy
    set -e all_proxy
    set -e http_proxy
    set -e https_proxy
end

if test -d (brew --prefix)"/share/fish/completions"
    set -p fish_complete_path (brew --prefix)/share/fish/completions
end

if test -d (brew --prefix)"/share/fish/vendor_completions.d"
    set -p fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
end

function _fzf_wrapper --description "Prepares some environment variables before executing fzf."
    # Make sure fzf uses fish to execute preview commands, some of which
    # are autoloaded fish functions so don't exist in other shells.
    # Use --function so that it doesn't clobber SHELL outside this function.
    set -f --export SHELL (command --search fish)

    # If neither FZF_DEFAULT_OPTS nor FZF_DEFAULT_OPTS_FILE are set, then set some sane defaults.
    # See https://github.com/junegunn/fzf#environment-variables
    set --query FZF_DEFAULT_OPTS FZF_DEFAULT_OPTS_FILE
    if test $status -eq 2
        # cycle allows jumping between the first and last results, making scrolling faster
        # layout=reverse lists results top to bottom, mimicking the familiar layouts of git log, history, and env
        # border shows where the fzf window begins and ends
        # height=90% leaves space to see the current command and some scrollback, maintaining context of work
        # preview-window=wrap wraps long lines in the preview window, making reading easier
        # marker=* makes the multi-select marker more distinguishable from the pointer (since both default to >)
        set --export FZF_DEFAULT_OPTS '--cycle --layout=reverse --border --height=90% --preview-window=wrap --marker="*"'
    end

    fzf $argv
end

starship init fish | source
atuin init fish | source
zoxide init fish | source
