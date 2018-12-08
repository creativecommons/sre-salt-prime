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


apt_install_salt_minion() {
    headerone 'Apt Install Salt Minion'
    if (( local_minion == 1 ))
    then
        apt install -y salt-minion
    else
        ssh -qt ${minion_ssh} 'sudo apt install -y salt-minion'
    fi
    echo
}


apt_update() {
    headerone 'Apt Update'
    if (( local_minion == 1 ))
    then
        apt update
    else
        ssh -qt ${minion_ssh} 'sudo apt update'
    fi
    echo
}


configure_etc_hosts() {
    local _hosts_entry
    (( local_minion == 0 )) || return 0
    (( local_subnet == 1 )) || return 0
    headerone 'Configure /etc/hosts For Local Salt Prime'
    if _hosts_entry=$(ssh -qt ${minion_ssh} "grep '^10.22.11.11' /etc/hosts")
    then
        headertwo '/etc/hosts already configured for local salt-prime'
        echo "${_hosts_entry}"
        echo
    else
        headertwo 'Add line'
        echo '10.22.11.11	salt-prime.creativecommons.org' \
            | ssh -qt ${minion_ssh} 'sudo tee -a /etc/hosts'
        echo
    fi
}


configure_prime_server() {
    local _file=/etc/salt/minion.d/prime_server.conf
    headerone 'Configure Prime Server on Salt Minion'
    headertwo 'File'
    echo ${_file}
    headertwo 'Contents'
    {
        echo "master: ${salt_prime_server}"
        echo "master_finger: '${salt_prime_key}'"
    } | if (( local_minion == 1 ))
    then
        sudo tee ${_file}
    else
        ssh -qt ${minion_ssh} "sudo tee ${_file}"
    fi
    echo
}


configure_minion_id() {
    local _file=/etc/salt/minion_id
    headerone 'Configure Minion ID'
    headertwo 'File'
    echo ${_file}
    headertwo 'Contents'
    echo "${minion_id}" | if (( local_minion == 1 ))
    then
        sudo tee ${_file}
    else
        ssh -qt ${minion_ssh} "sudo tee ${_file}"
    fi
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


create_minion_keys() {
    headerone 'Create, Install, and Accept Minion Key'
    # Create temporary directory
    mkdir -p TEMP__${minion_id}
    chmod 0770 TEMP__${minion_id}
    cd TEMP__${minion_id}
    # Create keys
    headertwo 'Minion Fingerprint'
    salt-key --gen-keys=${minion_id} --no-color | tail -n1 | xargs
    # Install (copy) keys to minion
    if (( local_minion == 1 ))
    then
        cp -a ${minion_id}.pem /etc/salt/pki/minion/minion.pem
        cp -a ${minion_id}.pub /etc/salt/pki/minion/minion.pub
    else
        ssh -qt ${minion_ssh} '
            sudo touch /etc/salt/pki/minion/minion.pem;
            sudo chmod 0400 /etc/salt/pki/minion/minion.pem;
            sudo touch /etc/salt/pki/minion/minion.pub;
            sudo chmod 0644 /etc/salt/pki/minion/minion.pub;
            '
        cat ${minion_id}.pem | ssh -qt ${minion_ssh} \
            'sudo tee /etc/salt/pki/minion/minion.pem >/dev/null'
        cat ${minion_id}.pub | ssh -qt ${minion_ssh} \
            'sudo tee /etc/salt/pki/minion/minion.pub >/dev/null'
    fi
    # Accept (copy) public key to prime
    cp -a ${minion_id}.pub /etc/salt/pki/master/minions/${minion_id}
    # Remove temporary directory
    cd ..
    sudo rm -rf TEMP__${minion_id}
    # Display files
    headertwo 'Minion key pair (on minion)'
    if (( local_minion == 1 ))
    then
        ls -l /etc/salt/pki/minion/minion.p*
    else
        ssh -qt ${minion_ssh} 'sudo ls -l /etc/salt/pki/minion/minion.pem \
            /etc/salt/pki/minion/minion.pub'
    fi
    headertwo 'Minion public key (on prime)'
    ls -l /etc/salt/pki/master/minions/${minion_id}
    echo
}


get_local_subnet_status() {
    (( local_minion == 0 )) || return 0
    headerone 'Is Remote Salt Minion On a Local Subnet'
    if ssh -qt ${minion_ssh} 'echo ${SSH_CLIENT}' | grep -q '^10[.]'
    then
        echo 'Yes'
        local_subnet=1
    else
        echo 'No'
        local_subnet=0
    fi
    echo
}


get_localhost_or_remote() {
    if [[ "${minion_ssh}" == '127.0.0.1' ]] || \
        [[ "${minion_ssh}" == 'localhost' ]]
    then
        local_minion=1
        salt_prime_server=localhost
    else
        local_minion=0
        salt_prime_server=salt-prime.creativecommons.org
    fi
}


get_salt_prime_key() {
    salt_prime_key=$(sudo salt-key -f master.pub \
                        | awk '/master.pub/ {print $2}')
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


require_sudo() {
    if (( ${UID} != 0 ))
    then
        error_exit 'Must be root (invoke with sudo)'
    fi
    return 0
}


minion_service_start() {
    headerone 'Start Salt Minion Service'
    if (( local_minion == 1 ))
    then
        service salt-minion start
    else
        ssh -qt ${minion_ssh} 'sudo service salt-minion start'
    fi
    echo 'Waiting 1 second following service start'
    minion_service_status
}


minion_service_status() {
    headertwo 'Status'
    if (( local_minion == 1 ))
    then
        systemctl --lines=0 --no-pager --output=short-iso \
            status salt-minion || true
    else
        ssh -qt ${minion_ssh} \
            'systemctl --lines=0 --no-pager --output=short-iso \
            status salt-minion || true'
    fi
    echo
}


minion_service_stop() {
    headerone 'Stop Salt Minion Service'
    if (( local_minion == 1 ))
    then
        service salt-minion stop
    else
        ssh -qt ${minion_ssh} 'sudo service salt-minion stop'
    fi
    echo 'Waiting 1 second following service stop'
    minion_service_status
}


test_minion() {
    headerone 'Test Salt Minion Connectivity'
    headertwo 'Waiting 3 seconds and then sending test.ping'
    sleep 3
    sudo salt ${minion_id} test.ping
    echo
}


#### MAIN #############################################################


minion_ssh=${1}
minion_name=${2}
minion_pod=${3}
minion_location=${4}
minion_id="${minion_name}__${minion_pod}__${minion_location}"
require_sudo
get_localhost_or_remote
get_salt_prime_key
get_local_subnet_status
apt_update
apt_install_salt_minion
minion_service_stop
configure_etc_hosts
configure_minion_id
configure_prime_server
create_minion_keys
minion_service_start
test_minion
