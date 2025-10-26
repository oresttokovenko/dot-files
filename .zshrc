###############################################################################
# Env Vars
###############################################################################

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export EDITOR="nvim"

###############################################################################
# Amazon Q Integration                                                        #
###############################################################################

[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && \
  builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"

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

###############################################################################
# fzf Integration (Homebrew install)                                          #
###############################################################################

# Load fzf key bindings and completion
if [[ -x "$(command -v fzf)" ]]; then
  fzf_home="$(brew --prefix fzf)/shell"
  [[ -f "$fzf_home/key-bindings.zsh" ]] && source "$fzf_home/key-bindings.zsh"
  [[ -f "$fzf_home/completion.zsh" ]] && source "$fzf_home/completion.zsh"
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

autoload -Uz compinit && compinit

# Replay compiled completions from cache
zinit cdreplay -q

# Alias to update all Zinit plugins easily
alias zinit-update='zinit self-update && zinit update --parallel'

###############################################################################
# Miscellaneous                                                               #
###############################################################################

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

# Starship bug - https://github.com/starship/starship/issues/3418#issuecomment-1711630970
type starship_zle-keymap-select >/dev/null || \
  {
    echo "Load starship"
    eval "$(/usr/local/bin/starship init zsh)"
  }

###############################################################################
# Amazon Q Integration                                                        #
###############################################################################

[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && \
    builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"
