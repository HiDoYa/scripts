# Modified (steeef) to work with jj (Jujutsu) VCS instead of git
# Install:
# cp jj-omz-theme/steeef-jj.zsh-theme ~/.oh-my-zsh/themes

export VIRTUAL_ENV_DISABLE_PROMPT=1

function virtualenv_info {
    [ $VIRTUAL_ENV ] && echo '('%F{blue}`basename $VIRTUAL_ENV`%f') '
}
PR_JJ_UPDATE=1

setopt prompt_subst

autoload -U add-zsh-hook
autoload -Uz vcs_info

#use extended color palette if available
if [[ $terminfo[colors] -ge 256 ]]; then
    turquoise="%F{81}"
    orange="%F{166}"
    purple="%F{135}"
    hotpink="%F{161}"
    limegreen="%F{118}"
else
    turquoise="%F{cyan}"
    orange="%F{yellow}"
    purple="%F{magenta}"
    hotpink="%F{red}"
    limegreen="%F{green}"
fi

# jj status function
function jj_status_info {
    if command -v jj >/dev/null 2>&1 && jj root >/dev/null 2>&1; then
        local jbookmark=$(jj log -r '::@ & bookmarks()' -T 'bookmarks.map(|c| c.name() ).join("\n") ++ "\n"' --no-graph -n 1)
        local jstatus=""
        local jconflicts=""

        # Check for conflicts (in current change)
        if jj log -r 'conflicts() & @' --no-graph 2>/dev/null | grep -q .; then
            jconflicts="%{$hotpink%}⚡"
        fi

        # Check for changes (in current change)
        if jj diff --summary 2>/dev/null | grep -q .; then
            jstatus="%{$orange%}●"
        fi

        if [[ -n "$jbookmark" ]]; then
            echo "(%{$turquoise%}${jbookmark}${jstatus}${jconflicts}${PR_RST}) "
        fi
    fi
}

PR_RST="%f"


function steeef_preexec {
    case "$2" in
        *jj*)
            PR_JJ_UPDATE=1
            ;;
    esac
}
add-zsh-hook preexec steeef_preexec

function steeef_chpwd {
    PR_JJ_UPDATE=1
}
add-zsh-hook chpwd steeef_chpwd

function steeef_precmd {
    if [[ -n "$PR_JJ_UPDATE" ]] ; then
        JJ_INFO=$(jj_status_info)
        PR_JJ_UPDATE=
    fi
}
add-zsh-hook precmd steeef_precmd

PROMPT=$'
%{$purple%}%n${PR_RST} at %{$orange%}%m${PR_RST} in %{$limegreen%}%~${PR_RST} $JJ_INFO$(virtualenv_info)
$ '
