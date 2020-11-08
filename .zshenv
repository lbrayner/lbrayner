# FZF
export FZF_DEFAULT_OPTS=--bind=ctrl-j:accept,ctrl-k:kill-line,\
ctrl-p:up,ctrl-n:down,\
alt-p:previous-history,alt-n:next-history

# less
export LESS="-R -F -X"

if [[ $(uname) =~ BSD ]]
then
    return
fi

# GNU ls colors
if [[ $(uname) == Linux || $(uname) =~ CYGWIN ]]
then
    [[ -f ~/.zshcolors ]] && . ~/.zshcolors
fi

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

# local environment configuration
[[ -f ~/.zshenv.local ]] && . ~/.zshenv.local

# vim:ft=zsh
