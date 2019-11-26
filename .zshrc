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

# https://github.com/wincent/wincent
# http://zsh.sourceforge.net/Doc/Release/Parameters.html#Array-Parameters
# Create a hash table for globally stashing variables without polluting main
# scope with a bunch of identifiers.
typeset -A __ZSH

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

# https://github.com/wincent/wincent
# Make CTRL-Z background things and unbackground them.
function fg-bg() {
  if [[ $#BUFFER -eq 0 ]]; then
    fg
  else
    zle push-input
  fi
}
zle -N fg-bg

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
bindkey '^z'      fg-bg
bindkey '^[Od'    backward-word
bindkey '^[Oc'    forward-word
bindkey '^[f'     forward-word
bindkey '^[OD'    backward-word
bindkey '^[b'     backward-word
bindkey '^[OC'    forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^ '      expand-alias

# Sourcing files

function source_file(){
    if [[ -f ${1} ]]
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

setopt prompt_subst

# https://github.com/wincent/wincent
# http://zsh.sourceforge.net/Doc/Release/User-Contributions.html
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git hg svn
zstyle ':vcs_info:git*:*' formats '[%b%m%c%u] ' # default ' (%s)-[%b]%c%u-'
zstyle ':vcs_info:git*:*' actionformats '[%b|%a%m%c%u] ' # default ' (%s)-[%b|%a]%c%u-'
zstyle ':vcs_info:svn*:*' formats '[%b%m] ' # default ' (%s)-[%b]%c%u-'
zstyle ':vcs_info:svn*:*' actionformats '[%b|%a%m] ' # default ' (%s)-[%b|%a]%c%u-'

# https://github.com/wincent/wincent
# Remember each command we run.
function record-last-command () {
    __ZSH[LAST_COMMAND]="${2}"
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec record-last-command

# https://github.com/wincent/wincent
# Update vcs_info (slow) after any command that probably changed it.
function maybe_show_vcs_info () {
    local last="${__ZSH[LAST_COMMAND]}"

    # In case user just hit enter, overwrite LAST_COMMAND, because preexec
    # won't run and it will otherwise linger.
    __ZSH[LAST_COMMAND]="<unset>"

    # Check first word; via:
    # http://tim.vanwerkhoven.org/post/2012/10/28/ZSH/Bash-string-manipulation

    case "$last[(w)1]" in
      cd|cp|git|rm|touch|mv)
          vcs_info
          ;;
      *)
          ;;
    esac
}

# http://aperiodic.net/phil/prompt/
# See if we can use extended characters to look nicer.

typeset -A ALTCHAR

# Substitutions: http://zsh.sourceforge.net/Guide/zshguide05.html
# http://zsh.sourceforge.net/Doc/Release/Expansion.html#Parameter-Expansion
# Parameter Expansion: s:string:
set -A ALTCHAR ${(s..)terminfo[acsc]}

# http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html
# %{...%} Include a string as a literal escape sequence
__ZSH[SET_CHARSET]="%{$terminfo[enacs]%}"
__ZSH[SHIFT_IN]="%{$terminfo[smacs]%}"
__ZSH[SHIFT_OUT]="%{$terminfo[rmacs]%}"
# Parameter Expansion: ${name:-word}
__ZSH[ULCORNER]=${__ZSH[SET_CHARSET]}${__ZSH[SHIFT_IN]}${ALTCHAR[l]:--}${__ZSH[SHIFT_OUT]}
__ZSH[LLCORNER]=${__ZSH[SET_CHARSET]}${__ZSH[SHIFT_IN]}${ALTCHAR[m]:--}${__ZSH[SHIFT_OUT]}
__ZSH[URCORNER]=${__ZSH[SET_CHARSET]}${__ZSH[SHIFT_IN]}${ALTCHAR[k]:--}${__ZSH[SHIFT_OUT]}
__ZSH[LRCORNER]=${__ZSH[SET_CHARSET]}${__ZSH[SHIFT_IN]}${ALTCHAR[j]:--}${__ZSH[SHIFT_OUT]}

# Upper Left and Right prompt

# Conditional Substrings in Prompts: %(x.true-text.false-text)
__ZSH[PROMPT_INFO]='%n@%M%(1j. (%j).): ${vcs_info_msg_0_}%B%~%b'
__ZSH[PROMPT_INFO_NO_ESC_SEQS]='%n@%M%(1j. (%j).): ${vcs_info_msg_0_}%~'
__ZSH[TIME_STRING]='%D{%Y} %D{%b} %D{%e} %D{%a} %D{%H}h%D{%M} %D{%S}s'

function set_prompt() {
    maybe_show_vcs_info

    # Parameter Expansion Flags: Prompt Expansion
   __ZSH[TIMESTAMP]="${(%)__ZSH[TIME_STRING]}"

    local termwidth
    (( termwidth = ${COLUMNS} - 2 - 1 - 1 )) # 2 ALTCHARs & 1 space & 1 extra space (RPROMPT)
    # Parameter Expansion Flags: parameter expansion, command substitution and
    # arithmetic expansion
    local prompt_contents="${(e%)__ZSH[PROMPT_INFO_NO_ESC_SEQS]}${__ZSH[TIMESTAMP]}"
    # length of scalar
    local contents_size=${#${prompt_contents}}

    if [[ ${contents_size} -gt ${termwidth} ]]
    then
        __ZSH[UL]=""
        __ZSH[LL]=""
        __ZSH[UR]=""
        __ZSH[LR]=""
        __ZSH[PROMPT_SPACER]=""
        __ZSH[TIMESTAMP]=""
        return
    fi

    __ZSH[UL]="${__ZSH[ULCORNER]}"
    __ZSH[LL]="${__ZSH[LLCORNER]}"
    __ZSH[UR]=" ${__ZSH[URCORNER]}"
    __ZSH[LR]=" ${__ZSH[LRCORNER]}"

    # Parameter Expansion Flags: l:expr::string1::string2:
    __ZSH[PROMPT_SPACER]="\${(l.((${termwidth} - ${contents_size})).. .)}"
}

add-zsh-hook precmd set_prompt

# Setting the PROMPT variable
PROMPT='${__ZSH[UL]}'"${__ZSH[PROMPT_INFO]}"'${(e)__ZSH[PROMPT_SPACER]}${__ZSH[TIMESTAMP]}'\
$'${__ZSH[UR]}\n${__ZSH[LL]}$ '

# Single-line prompt if SSH but not TMUX
if [[ -n "${SSH_TTY}" ]] && [[ -z "${TMUX}" ]]
then
    add-zsh-hook -d precmd set_prompt
    add-zsh-hook precmd maybe_show_vcs_info
    __ZSH[LR]=""
    PROMPT="${__ZSH[PROMPT_INFO]}\$ "
fi

# RPROMPT

# print: http://zsh.sourceforge.net/Doc/Release/Shell-Builtin-Commands.html
# https://superuser.com/a/911665/750142

# https://vi.stackexchange.com/a/14203
# tmux: DCS sequence
function steady_ibeam (){
    if [[ -n "${TMUX}" ]]
    then
        print -Pn "\ePtmux;\e\e[6 q\e\\"
        return
    fi
	print -Pn "\e[6 q"
}

function steady_block (){
    if [[ -n "${TMUX}" ]]
    then
        print -Pn "\ePtmux;\e\e[2 q\e\\"
        return
    fi
	print -Pn "\e[2 q"
}

# http://zsh.sourceforge.net/Doc/Release/Functions.html#Hook-Functions
function preexec (){
    steady_block
}

__ZSH[INSERT]="-- INSERT --"
__ZSH[NORMAL]="[NORMAL]"

function rprompt_cmd (){
    RPROMPT="${__ZSH[NORMAL]}"'${__ZSH[LR]}'
}

function rprompt_insert (){
    RPROMPT="${__ZSH[INSERT]}"'${__ZSH[LR]}'
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
        rprompt_cmd
    else
        # the insert mode for vi
        steady_ibeam
        rprompt_insert
    fi

    zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select

vcs_info

if [[ "${TERM#*256}" != "${TERM}" ]]
then
    rprompt_insert
fi
