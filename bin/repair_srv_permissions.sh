#!/bin/bash
set -o errexit
set -o errtrace
set -o nounset

trap '_es=${?};
    _lo=${LINENO};
    _co=${BASH_COMMAND};
    echo "${0}: line ${_lo}: \"${_co}\" exited with a status of ${_es}";
    exit ${_es}' ERR

ENV_GROUP=salt

#### FUNCTIONS ########################################################


configure_git_shared_repo() {
    headerone 'Configure git repositories to be shared repositories'
    local _current=$(git config core.sharedRepository)
    if [[ "${_current}" != 'group' ]]
    then
        git config core.sharedRepository group
        echo "Configured ${PWD}"
    fi
    headertwo DONE
    echo
}


ensure_all_are_group_writeable() {
    headerone 'Ensure all user writeable dirs/files are also group writeable'
    # man find excerpt:
    # "Never follow symbolic links. This is the default behaviour."
    find . -perm /u+w -not -perm /g+w -exec chmod -v g+w {} +
    headertwo DONE
    echo
}


ensure_all_grouped_correctly() {
    headerone 'Ensure all files have sudo group'
    # man find excerpt:
    # "Never follow symbolic links. This is the default behaviour."
    find . -not -group "${ENV_GROUP}" -exec chgrp -v "${ENV_GROUP}" {} +
    headertwo DONE
    echo
}


ensure_dirs_have_set_group_id() {
    headerone 'Ensure all directories have set-group-id'
    # man find excerpt:
    # "Never follow symbolic links. This is the default behaviour."
    find . -type d -not -perm /g+s -exec chmod -v g+s {} +
    headertwo DONE
    echo
}


ensure_other_has_no_permisions() {
    headerone 'Ensure other has no permissions'
    # man chmod excerpt:
    # "chmod ignores symbolic links encountered during recursive directory
    # traversals."
    chmod --preserve-root --recursive o-rwx .
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
    find . -user admin -exec chown -v ${SUDO_USER} {} + || true
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


#### MAIN #############################################################

require_sudo
# Change directory to repository root
# (parent directory of this script's location)
pushd "${0%/*}/.." >/dev/null
# Repair permissions
replace_admin
ensure_other_has_no_permisions
ensure_all_grouped_correctly
ensure_all_are_group_writeable
ensure_dirs_have_set_group_id
configure_git_shared_repo
