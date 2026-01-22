###############################################################################
# Env Vars
###############################################################################

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export EDITOR="nvim"
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"

###############################################################################
# PATH
###############################################################################

eval "$(/opt/homebrew/bin/brew shellenv)"

export PATH="$HOME/.local/share/bob/nvim-bin:$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"

[ -f ~/.zshrc.local ] && source ~/.zshrc.local

###############################################################################
# Ghostty Shell Integration                                                   #
###############################################################################

if [ -n "${GHOSTTY_RESOURCES_DIR}" ]; then
  builtin source "${GHOSTTY_RESOURCES_DIR}/shell-integration/zsh/ghostty-integration"
fi

###############################################################################
# Zinit Bootstrap                                                             #
###############################################################################

zinit_home="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $zinit_home ] && mkdir -p "$(dirname $zinit_home)"
[ ! -d $zinit_home/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$zinit_home"
source "${zinit_home}/zinit.zsh"

# Load zsh-autocomplete
zinit light marlonrichert/zsh-autocomplete

###############################################################################
# fzf Configuration                                                           #
###############################################################################

# Customize fzf Ctrl-R (reverse search) behavior
export FZF_CTRL_R_OPTS="
  --reverse
  --height=40%
  --border
  --color=fg:#d0d0d0,bg:-1,hl:#87afff
  --color=fg+:#ffffff,bg+:-1,hl+:#ffd75f
  --preview 'echo {}' --preview-window down:3:hidden:wrap
"

###############################################################################
# Vi Mode & Keybindings                                                       #
###############################################################################

autoload -Uz edit-command-line
zle -N edit-command-line

# Custom escape for zsh-vi-mode
ZVM_VI_INSERT_ESCAPE_BINDKEY=jk

# Custom keymaps
bindkey -M vicmd "H" beginning-of-line
bindkey -M vicmd "L" end-of-line
bindkey -M visual "H" beginning-of-line
bindkey -M visual "L" end-of-line
bindkey '^R' fzf-history-widget
bindkey '^O' edit-command-line

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

# Alias to update all Zinit plugins easily
alias zinit-update='zinit self-update && zinit update --parallel'

###############################################################################
# Miscellaneous                                                               #
###############################################################################

# Convert ticket names into branch names
branchify() {
  local result="${1// /_}"
  result="${(L)result}"
  echo "$result" | pbcopy
}

# Modern Tree replacement
tree() {
  local level=${1:-2}
  shift 2>/dev/null
  eza --tree --level="$level" --icons "$@"
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

# eval "$(fnm env --use-on-cd)"
eval "$(starship init zsh)"
eval "$(jump shell)"
eval "$(fzf --zsh)"

# Lazy-load NVM for faster shell startup
export NVM_DIR="$HOME/.nvm"
lazy_load_nvm() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}
nvm() { lazy_load_nvm && nvm "$@"; }
node() { lazy_load_nvm && node "$@"; }
npm() { lazy_load_nvm && npm "$@"; }
npx() { lazy_load_nvm && npx "$@"; }
