SPCTLisDisabled=1
CURRENT_USER=$(stat -f '%Su' /dev/console)


if [[ $(whoami) != "root" ]]; then
    echo "I will need root privelegies. \nType your \033[31mmac-password and press Enter.\033[0m"
fi
    SPCTLisDisabled=$(sudo spctl --status)
if [[ $SPCTLisDisabled = "assessments enabled" ]]; then
    sudo spctl --master-disable
fi

#install components

#Use ZSH
chsh -s /bin/zsh
# Homebrew
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
#iterm2
brew install iterm2 --cask
#oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
brew install zsh-syntax-highlighting
