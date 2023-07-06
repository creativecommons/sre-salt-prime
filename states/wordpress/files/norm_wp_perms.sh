#!/bin/bash
#
# Normalize WordPress permissions
#
# Goals:
# - Maximize security / minimize risk
# - Allow web development without requiring root privilages
#
# References
# - https://wordpress.org/support/article/changing-file-permissions/
# - https://www.gnu.org/software/coreutils/manual/html_node/Directory-Setuid-and-Setgid.html
#
set -o errexit
set -o errtrace
set -o nounset

trap '_es=${?};
    printf "${0}: line ${LINENO}: \"${BASH_COMMAND}\"";
    printf " exited with a status of ${_es}\n";
    exit ${_es}' ERR

#### FUNCTIONS ########################################################

headerone() {
    printf '\e[107m\e[30m'
    printf '### %-75s' "${1}"
    printf '\e[0m'
    echo
}

headertwo() {
    printf '\e[47m\e[30m'
    printf '# %-77s' "${1}"
    printf '\e[0m'
    echo
}

#### MAIN #############################################################

# Require sudo
if (( ${UID} != 0 ))
then
    error_exit 'Must be root (invoke with sudo)'
fi

# Find WordPress installations
WP_CONFIGS=$(find /var/www -maxdepth 2 -type f -name 'wp-config.php' \
                2>/dev/null \
                || true)
for _wp_config in ${WP_CONFIGS}
do
    WP_DIR="${_wp_config%/*}"
    headerone 'Normalzing permissions on WordPress top directory:'
    # composer.json file
    TARGET="${WP_DIR}/composer.json"
    headertwo "${TARGET}"
    if [[ -f "${TARGET}" ]]
    then
        chgrp -ch webdev "${TARGET}"
        chmod -c 00664 "${TARGET}"
    fi
    # backup directory
    TARGET="${WP_DIR}/backup"
    headertwo "${TARGET}"
    if [[ -d "${TARGET}" ]]
    then
        chown -ch root "${TARGET}"
        chgrp -chR webdev "${TARGET}"
        chmod -c 2770 "${TARGET}"
        /usr/bin/find "${TARGET}" \
            -type d -exec chmod -c 2770 {} + \
            -o -type f -exec chmod -c 0660 {} + \
            | sed -e'/retained as/d'
    fi
    # vendor symlink - unnecessary aesthetics ¯\_(ツ)_/¯
    TARGET="${WP_DIR}/vendor"
    headertwo "$(printf '%-43s (symlink)\n' "${TARGET}")"
    if [[ -L "${TARGET}" ]]
    then
        chown -chR composer:webdev "${TARGET}"
    fi
    # wp directory
    TARGET="${WP_DIR}/wp"
    headertwo "${TARGET}"
    if [[ -d "${TARGET}" ]]
    then
        chown -chR composer:webdev "${TARGET}"
        chmod -c 2775 "${TARGET}"
        /usr/bin/find "${TARGET}" \
            -type d -exec chmod -c 2775 {} + \
            -o -type f -exec chmod -c 0664 {} + \
            | sed -e'/retained as/d'
    fi
    # wp-content directory
    TARGET="${WP_DIR}/wp-content"
    headertwo "${TARGET}"
    if [[ -d "${TARGET}" ]]
    then
        chown -ch root:root "${TARGET}"
        chmod -c 00555 "${TARGET}"
        # wp-content subdirectories
        for _dir in $(/usr/bin/find "${TARGET}" -maxdepth 1 -type d)
        do
            TARGET_USER=composer
            TARGET_GROUP=webdev
            TARGET_FMODE=00664
            case ${_dir} in
                "${TARGET}")
                    continue
                    ;;
                *uploads)
                    TARGET_USER=www-data
                    TARGET_GROUP=www-data
                    ;;
                *wflogs)
                    TARGET_USER=www-data
                    TARGET_GROUP=www-data
                    TARGET_FMODE=00660
                    ;;
            esac
            headertwo "$(printf '%-43s group: %s\n' "${_dir}" \
                            "${TARGET_GROUP}")"
            chown -chR "${TARGET_USER}":"${TARGET_GROUP}" "${_dir}"
            /usr/bin/find "${_dir}" \
                -type d -exec chmod -c 2775 {} + \
                -o -type f -exec chmod -c "${TARGET_FMODE}" {} +
        done
    fi
done
