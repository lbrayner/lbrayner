# http://zsh.sourceforge.net/Doc/Release/Parameters.html

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
KEYTIMEOUT=1

# https://stackoverflow.com/a/15394738
# will not clobber fpath
local_functions=$HOME/.zfunc/functions
if [[ ! " ${fpath[@]} " =~ " ${local_functions} " ]]; then
    fpath=( "${local_functions}" "${fpath[@]}" )
fi
# vi insert mode keymap
bindkey -v
autoload -Uz compinit
compinit

# http://zsh.sourceforge.net/Doc/Release/Options.html

setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt GLOB_COMPLETE
setopt complete_aliases
setopt extended_glob

# http://zsh.sourceforge.net/Doc/Release/Functions.html#Functions

autoload -U select-word-style
select-word-style bash

# zle, The Z-Shell Line Editor: http://zsh.sourceforge.net/Guide/zshguide04.html

# Widgets

autoload -Uz copy-earlier-word
zle -N copy-earlier-word

autoload -Uz insert-newest-file
zle -N insert-newest-file

autoload -Uz smart-insert-last-word
zle -N insert-last-word smart-insert-last-word

function expand-alias() {
    zle _expand_alias
    zle expand-word
}

zle -N expand-alias

# Binding keys and handling keymaps

bindkey '^[;'     insert-newest-file
bindkey '^[.'     insert-last-word
bindkey '^[m'     copy-earlier-word
bindkey '^[d'     kill-word
bindkey '^P'      up-history
bindkey '^N'      down-history
bindkey '^?'      backward-delete-char
bindkey '^h'      backward-delete-char
bindkey '^w'      backward-kill-word
bindkey '^u'      backward-kill-line
bindkey '^r'      history-incremental-search-backward
bindkey '^k'      kill-line
bindkey '^[Od'    backward-word
bindkey '^[Oc'    forward-word
bindkey '^[f'     forward-word
bindkey '^[OD'    backward-word
bindkey '^[b'     backward-word
bindkey '^[OC'    forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^ '      expand-alias

# normal mode bindings
bindkey -a '\e[3~' delete-char
bindkey -a '\e[1~' beginning-of-line
bindkey -a '\e[4~' end-of-line

# Sourcing files

function source_file(){
    if [ -f ${1} ]
    then
        source ${1}
    fi
}

# interactive shells
# user is responsible for not clobbering environment variables
source_file ~/.profile

# setting environment variables
# user is responsible for not clobbering environment variables
source_file ~/.zsh-env

# setting local environment variables
# user is responsible for not clobbering environment variables
source_file ~/.zsh-env.local

# setting aliases
source_file ~/.zsh-alias

# setting local aliases
source_file ~/.zsh-alias.local

# colors
source_file ~/.zsh-colors

###            ###
### The prompt ###
###            ###

LEFT='[%n@%M] %B%~%b'
LEFT_NO_ESC_SEQS='[%n@%M ]%~'
RIGHT='[%D{%Y} %D{%b} %D{%e}] %D{%K}h%D{%M} %D{%S}s'

# http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html
# http://zsh.sourceforge.net/Doc/Release/Expansion.html#Parameter-Expansion
# Substitutions: http://zsh.sourceforge.net/Guide/zshguide05.html
function set_prompt() {
    # Parameter Expansion Flags: Prompt Expansion
    local right_exp="${(%)RIGHT}"

    local termwidth
    (( termwidth = ${COLUMNS} - 1 - 1 )) # 2 extra spaces
    local prompt_contents="${(%)LEFT_NO_ESC_SEQS}-${right_exp}"
    # length of scalar
    local prompt_size=${#${prompt_contents}}

    if [[ ${prompt_size} -gt ${termwidth} ]]
    then
        PROMPT="${LEFT}"$'\n$ '
        return
    fi

    # Parameter Expansion Flags: l:expr::string1::string2:
    PROMPT_SPACER="\${(l.(($termwidth - $prompt_size)).. .)}"

    # Parameter Expansion Flags: single word shell expansions
    PROMPT="${LEFT} "'${(e)PROMPT_SPACER}'" ${right_exp}"$'\n$ '
}

setopt prompt_subst

autoload -Uz add-zsh-hook
add-zsh-hook precmd set_prompt

INSERT="-- INSERT --"
NORMAL="[NORMAL]"

# print: http://zsh.sourceforge.net/Doc/Release/Shell-Builtin-Commands.html
# https://superuser.com/a/911665/750142

function steady_ibeam (){
	print -Pn "\e[6 q"
}

function steady_block (){
	print -Pn "\e[2 q"
}

# http://zsh.sourceforge.net/Doc/Release/Functions.html#Hook-Functions
function preexec (){
    steady_block
}

function zle-line-init zle-keymap-select () {
    if [[ "${TERM#*256}" = "${TERM}" ]]
    then
        return
    fi

    if [[ $KEYMAP = vicmd ]]
    then
        # the command mode for vi
        steady_block
        RPROMPT=${NORMAL}
    else
        # the insert mode for vi
        steady_ibeam
        RPROMPT=${INSERT}
    fi

    zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select

RPROMPT=${INSERT}
