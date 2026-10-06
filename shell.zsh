# Public baseline only. Keep private aliases and credentials outside this file.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
if command -v brew >/dev/null 2>&1; then
  _kostinos_brew_prefix="$(brew --prefix)"
  fpath=("$_kostinos_brew_prefix/share/zsh-completions" $fpath)
fi
# Preserve an existing Oh My Zsh configuration already loaded by .zshrc.
if [[ -z "${ZSH:-}" && -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
  export ZSH="$HOME/.oh-my-zsh"
  ZSH_THEME=robbyrussell
  plugins=(git)
  source "$ZSH/oh-my-zsh.sh"
else
  autoload -Uz compinit
  compinit
fi
if [[ -n "${_kostinos_brew_prefix:-}" && -f "$_kostinos_brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$_kostinos_brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
unset _kostinos_brew_prefix
