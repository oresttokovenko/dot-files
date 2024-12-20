###############################################################################
# zinit Config                                                                #
###############################################################################

zinit ice depth=1
zinit light jeffreytse/zsh-vi-mode

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
# Miscelleanious                                                              #
###############################################################################

export STARSHIP_CONFIG=~/.config/starship.toml

# Remove the title from the terminal window
DISABLE_AUTO_TITLE="true"

# Home directory
XDG_CONFIG_HOME="$HOME/.config"

# Prevent fastfetch from being printing in vs code
if [ "$TERM_PROGRAM" != "vscode" ]; then
    fastfetch --config ~/.config/fastfetch/config.jsonc
fi

# Convert ticket names into branch names
branchify() {
    local result="$(echo $1 | tr '[:upper:]' '[:lower:]')"
    result="${result// /_}"
    result="${result%%_}"
    echo "$result" | pbcopy
}

###############################################################################
# Aliases                                                                     #
###############################################################################

# Modern equivalent of cat
alias cat="bat --paging=never"

# Modern equivalent of ls
alias ll="eza --long --header --icons --no-permissions --no-user --modified --color-scale"
alias lt="eza --long --header --icons --no-permissions --no-user --modified --color-scale --tree"
alias ls="eza --header --icons --no-permissions --no-user --modified --color-scale --all --grid"

# remapping neovim to vim
alias vim="nvim"

# Easily open .zshrc file in VS Code
alias ezsh="nvim ~/.zshrc"

###############################################################################
# Evals                                                                       #
###############################################################################

# This section is designated for 'eval' expressions that are necessary for 
# initializing version management tools such as pyenv, nvm, or others. These tools 
# often require an 'eval' command to be executed to set up the environment 
# correctly by modifying PATH or other shell variables.
