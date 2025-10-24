###############################################################################
# Zinit Bootstrap                                                             #
###############################################################################

# Automatically install Zinit if not already present
if [[ ! -f ${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git/zinit.zsh ]]; then
  echo "Installing Zinit..."
  mkdir -p ${XDG_DATA_HOME:-${HOME}/.local/share}/zinit
  git clone https://github.com/zdharma-continuum/zinit.git \
    ${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git
fi
source ${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git/zinit.zsh

###############################################################################
# fzf Integration (Homebrew install)                                          #
###############################################################################

# Load fzf key bindings and completion (Homebrew paths)
if [[ -x "$(command -v fzf)" ]]; then
  # Key bindings
  if [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]]; then
    source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
  fi

  # Completions
  if [[ -f /opt/homebrew/opt/fzf/shell/completion.zsh ]]; then
    source /opt/homebrew/opt/fzf/shell/completion.zsh
  fi
fi

# Customize fzf Ctrl-R (reverse search) behavior
export FZF_CTRL_R_OPTS="
  --reverse
  --height=40%
  --border
  --color=fg:#d0d0d0,bg:-1,hl:#87afff
  --color=fg+:#ffffff,bg+:-1,hl+:#ffd75f
  --preview 'echo {}' --preview-window down:3:hidden:wrap
"

# Rebind Ctrl-R to fuzzy history search
bindkey '^R' fzf-history-widget

###############################################################################
# zsh-vi-mode Config                                                          #
###############################################################################

# Custom escape for zsh-vi-mode
ZVM_VI_INSERT_ESCAPE_BINDKEY=jk

# Custom keymaps
bindkey -M vicmd "H" beginning-of-line
bindkey -M vicmd "L" end-of-line
bindkey -M visual "H" beginning-of-line
bindkey -M visual "L" end-of-line

###############################################################################
# Zinit Plugins                                                               #
###############################################################################

# Load zsh-vi-mode (lazy-loaded for faster startup)
zinit wait lucid light-mode for jeffreytse/zsh-vi-mode

# Load Oh-My-Zsh plugin snippets
zinit wait lucid for \
  OMZP::terraform \
  OMZP::colored-man-pages \
  OMZP::command-not-found

# Replay compiled completions from cache
zinit cdreplay -q

# Alias to update all Zinit plugins easily
alias zinit-update='zinit self-update && zinit update --parallel'

###############################################################################
# Miscellaneous                                                               #
###############################################################################

# Home directory
XDG_CONFIG_HOME="$HOME/.config"

# Convert ticket names into branch names
branchify() {
  local result="${1// /_}"
  result="${result,,}"
  echo "$result" | pbcopy
}

# Modern Tree replacement
tree() {
  local level=${1:-2}
  eza --tree --level="$level" --icons
}

###############################################################################
# Aliases                                                                     #
###############################################################################

# Modern equivalent of cat
alias cat="bat --paging=never"

# Modern equivalents of ls
alias ll="eza --long --header --icons --no-permissions --no-user --modified --color-scale"
alias lt="eza --long --header --icons --no-permissions --no-user --modified --color-scale --tree"
alias ls="eza --header --icons --no-permissions --no-user --modified --color-scale --all --grid"

# Remap Neovim to vim
alias vim="nvim"

# Easily open .zshrc file in Neovim
alias ezsh="nvim ~/.zshrc"

###############################################################################
# Evals                                                                       #
###############################################################################

# This section is designated for 'eval' expressions required to initialize
# version management tools such as pyenv, nvm, or others. These tools often
# require an 'eval' command to modify PATH or other shell variables properly.
