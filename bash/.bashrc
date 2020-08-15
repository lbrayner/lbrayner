#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

# What follows are my additions

#
# Options
#

HISTCONTROL=ignoreboth

#
# Adding to $PATH
#

insertpath () {
    case ":$PATH:" in
        *:"$1":*)
            ;;
        *)
            PATH=${1}:${PATH}
    esac
}

# Adding ~/bin to $PATH
insertpath ~/bin

export PATH

#
# Variables
#

export EDITOR=/usr/bin/vim

#
# Aliases
#

alias lm='ls -lrth'
alias rsync='rsync --progress'
alias ta='tmux attach'
