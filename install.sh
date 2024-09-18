#!/usr/bin/env sh

# Install xCode cli tools
echo "Installing commandline tools..."
xcode-select --install

# Homebrew
## Install
echo "Installing Brew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew analytics off

## Taps
echo "Tapping Brew..."
brew tap homebrew/cask-fonts
brew tap FelixKratz/formulae
brew tap koekeishiya/formulae

## Formulae
echo "Installing Brew Formulae..."
### Essentials
brew install gsl
brew install llvm
brew install boost
brew install libomp
brew install wget
brew install jq
brew install ripgrep
brew install bear
brew install gh
brew install ifstat
brew install switchaudio-osx
brew install skhd
brew install sketchybar
brew install borders
brew install yabai
brew install yazi
brew install cava
brew install spotify_player
brew install spicetify
brew install nowplaying-cli
brew install lua
brew install luajit
brew install luarocks
brew install sptlrx

### Terminal
brew install neovim
brew install starship
brew install zsh-autosuggestions
brew install zsh-fast-syntax-highlighting
brew install zoxide

### Nice to have
brew install btop
brew install lazygit

## Casks
echo "Installing Brew Casks..."
### Terminals & Browsers
brew install --cask kitty

### Office
brew install --cask inkscape
brew install --cask vlc

### Nice to have
brew install --cask raycast
brew install --cask spotify
brew install --cask hammerspoon
brew install --cask bettertouchtool

### Fonts
brew install --cask sf-symbols
brew install --cask font-cascadia-code
brew install --cask homebrew/cask-fonts/font-sf-mono
brew install --cask homebrew/cask-fonts/font-sf-pro

# symbol link
ln -s ~/.config/.zshrc ~/.zshrc
ln -s ~/.config/hammerspoon/ ~/.hammerspoon

# install skectybar
curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.5/sketchybar-app-font.ttf -o $HOME/Library/Fonts/sketchybar-app-font.ttf

# SbarLua
(git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua/ && make install && rm -rf /tmp/SbarLua/)

echo "Cloning Config"
git clone https://github.com/xbunax/dotfiles.git ~/xbunax_dotfiles
mv $HOME/.config/sketchybar $HOME/.config/sketchybar_backup
mv ~/xbunax_dotfiles/sketchybar $HOME/.config/sketchybar
brew services restart sketchybar
