HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
# https://stackoverflow.com/a/15394738
# will not clobber fpath
local_functions=$HOME/.zfunc/functions
if [[ ! " ${fpath[@]} " =~ " ${local_functions} " ]]; then
    fpath=( "${local_functions}" "${fpath[@]}" )
fi
bindkey -v
autoload -Uz compinit
compinit

setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt GLOB_COMPLETE
setopt complete_aliases
setopt extended_glob

autoload -U select-word-style
select-word-style bash

autoload -Uz copy-earlier-word
zle -N copy-earlier-word

autoload -Uz insert-newest-file
zle -N insert-newest-file
autoload -Uz smart-insert-last-word
zle -N insert-last-word smart-insert-last-word

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

function source_file(){
    if [ -f ${1} ]
    then
        source ${1}
    fi
}

function expand-alias() {
    zle _expand_alias
    zle expand-word
}

zle -N zle-line-init
zle -N zle-keymap-select
zle -N expand-alias
KEYTIMEOUT=1

# interactive shells
# user is responsible for not clobbering environment variables
source_file ~/.profile

# setting environment variables
# user is responsible for not clobbering environment variables
source_file ~/.zsh-env

# setting local environment variables
source_file ~/.zsh-env.local

# setting aliases
source_file ~/.zsh-alias

# setting local aliases
source_file ~/.zsh-alias.local

# colors
source_file ~/.zsh-colors

# The prompt

function preexec() {
	print -Pn "\e]0;$1\a"
}

setopt prompt_subst

autoload -Uz add-zsh-hook

PROMPT_LEFT='[%n@%M:%B%~%b]'
PROMPT_LEFT_NO_ESC_SEQS='[%n@%M:%~]'

PROMPT_RIGHT='[$(date "+%Y %b %e %H:%M:%S")]'
PROMPT_RIGHT_TEMPLATE='[2019 Jun 26 19:17:40]'

function set_prompt() {
    local termwidth
    (( termwidth = ${COLUMNS} - 1 - 1 ))
    local prompt_contents="${(%)PROMPT_LEFT_NO_ESC_SEQS}-${PROMPT_RIGHT_TEMPLATE}"
    local prompt_size=${#${prompt_contents}}
    local spacer_char=' '
    PROMPT_SPACER="\${(l.(($termwidth - $prompt_size))..${spacer_char}.)}"

    PROMPT="${PROMPT_LEFT} "'${(e)PROMPT_SPACER}'" ${PROMPT_RIGHT}"$'\n$ '
}

add-zsh-hook precmd set_prompt

INSERT="-- INSERT --"
NORMAL="[NORMAL]"

function zle-line-init zle-keymap-select () {
    if [ -n "${TERM#*256*}" ]; then
        if [ $KEYMAP = vicmd ]; then
            # the command mode for vi
            RPROMPT=${NORMAL}
        else
            # the insert mode for vi
            RPROMPT=${INSERT}
        fi

		zle reset-prompt
    fi
}

RPROMPT=${INSERT}
