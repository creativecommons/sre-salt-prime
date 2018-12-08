#!/bin/bash
set -o errexit
set -o errtrace
set -o nounset

trap '_es=${?};
    _lo=${LINENO};
    _co=${BASH_COMMAND};
    echo "${0}: line ${_lo}: \"${_co}\" exited with a status of ${_es}";
    exit ${_es}' ERR


#### FUNCTIONS ########################################################


configure_git_shared_repo() {
    headerone 'Configure git repositories to be shared repositories'
    for _git in $(find /srv -type d -name .git -prune)
    do
        local _repo=${_git%/*}
        pushd ${_repo} >/dev/null
        local _current=$(git config core.sharedRepository)
        if [[ "${_current}" != 'group' ]]
        then
            git config core.sharedRepository group
            echo "Configured ${PWD}"
        fi
        popd >/dev/null
    done
    headertwo DONE
    echo
}


ensure_all_are_group_writeable() {
    headerone 'Ensure all user writeable dirs/files are also group writeable'
    find /srv -not -name 'lost+found' -perm /u+w -not -perm /g+w \
        -exec chmod -v g+w {} +
    headertwo DONE
    echo
}


ensure_all_grouped_by_sudo() {
    headerone 'Ensure all files have sudo group'
    find /srv -not -group sudo -not -name 'lost+found' \
        -exec chgrp -v sudo {} +
    headertwo DONE
    echo
}


ensure_dirs_have_set_group_id() {
    headerone 'Ensure all directories have set-group-iD'
    find /srv -type d -not -name 'lost+found' -not -perm /g+s \
        -exec chmod -v g+s {} +
    headertwo DONE
    echo
}


error_exit() {
    # Display error message and exit
    local _es _msg
    _msg=${1}
    _es=${2:-1}
    echo "ERROR: ${_msg}" 1>&2
    exit ${_es}
}



headerone() {
    printf '\e[107m\e[30m'
    printf '### %-75s' "${1}"
    printf '\e[0m'
    echo
}


headertwo() {
    printf '\e[47m\e[30m'
    printf "# ${1}"
    printf '\e[0m'
    echo
}


replace_admin() {
    headerone "Replace admin owner with current user (${SUDO_USER})"
    find /srv -user admin -exec chown -v ${SUDO_USER} {} +
    headertwo DONE
    echo
}


require_sudo() {
    if (( ${UID} != 0 ))
    then
        error_exit 'Must be root (invoke with sudo)'
    fi
    return 0
}


strip_other_permissions_for_within_srv() {
    headerone 'Strip other permissions for/within /srv'
    find /srv -maxdepth 1 \( -perm -o+r -o -perm -o+w -o -perm -o+x \) \
        -exec chmod -v o-rwx {} +
    headertwo DONE
    echo
}


#### MAIN #############################################################

require_sudo
replace_admin
ensure_all_grouped_by_sudo
ensure_all_are_group_writeable
ensure_dirs_have_set_group_id
strip_other_permissions_for_within_srv
configure_git_shared_repo
