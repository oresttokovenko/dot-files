###############################################################################
# ohmyzsh Config                                                              #
###############################################################################

plugins=(git zsh-vi-mode)

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
alias ll="exa --long --header --icons --no-permissions --no-user --modified --color-scale"
alias la="exa --long --header --icons --no-permissions --no-user --modified --color-scale --all"

# Output the terminal history into a fzf buffer
alias fhist="history -n | fzf --tac | pbcopy"

# Measure the internet connection performance 
alias speedtest="networkQuality -v"

# Easily open .zshrc file in VS Code
alias ezsh="code -n ~/.zshrc"

# Open ChatGPT as a Chrome App
alias chatgpt="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --app=http://chat.openai.com"

###############################################################################
# Evals                                                                       #
###############################################################################

# This section is designated for 'eval' expressions that are necessary for 
# initializing version management tools such as pyenv, nvm, or others. These tools 
# often require an 'eval' command to be executed to set up the environment 
# correctly by modifying PATH or other shell variables.
