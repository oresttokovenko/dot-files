###############################################################################
# ohmyzsh Config                                                              #
###############################################################################

plugins=(git zsh-vi-mode)

###############################################################################
# zsh-vi-mode Config                                                          #
###############################################################################

# Custom escape for zsh-vi-mode
ZVM_VI_INSERT_ESCAPE_BINDKEY=jk

###############################################################################
# Miscelleanious                                                              #
###############################################################################

# Remove the title from the terminal window
DISABLE_AUTO_TITLE="true"

# Prevent neofetch from being printing in vs code
if [ "$TERM_PROGRAM" != "vscode" ]; then
    neofetch
fi

# Convert Jira ticket names into branch names
branchify() {
    local result="$(echo $1 | tr '[:upper:]' '[:lower:]')"
    result="${result// /_}"
    result="${result%%_}"
    echo "$result"
}

###############################################################################
# Aliases                                                                     #
###############################################################################

# Modern equivalent of cat
alias cat="bat --paging=never"

# Modern equivalent of ls
alias ll="exa --long --header --group --git --modified --color-scale"

# Output the terminal history into a vim buffer
alias vhist="vim <(history -n | tail -r)"

# Measure the internet connection performance 
alias speedtest="networkQuality -v"

###############################################################################
# Evals                                                                       #
###############################################################################

# This section is designated for 'eval' expressions that are necessary for 
# initializing version management tools such as pyenv, nvm, or others. These tools 
# often require an 'eval' command to be executed to set up the environment 
# correctly by modifying PATH or other shell variables.
