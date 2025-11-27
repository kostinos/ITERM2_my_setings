#install components

#Use ZSH
chsh -s /bin/zsh
# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
#iterm2
brew install git
brew install htop
brew install nmap
cask install betterzip
brew install --cask openinterminal
brew install telnet
brew install wget
brew install --cask iterm2
brew install --cask raycast
brew install --cask visual-studio-code
brew install --cask tor-browser
brew install --cask google-chrome
brew install --cask spotify
brew install --cask telegram
brew install --cask wireshark-app

#oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
brew install zsh-syntax-highlighting
