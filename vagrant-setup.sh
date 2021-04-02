#!/bin/bash

# color des
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC1='\033[0m'

cwd=$PWD
__file__=$(basename $0)
log_name=$(basename $__file__ .sh).log
men_num=4096
disksize_default=50
gui_mode=true
run_mode=False
logdir=$cwd/reports
vagrant_home=$HOME/Desktop/vagrant-home
revision="$(grep 'Rev:' README.md | grep -Eo '([0-9]+\.){2}[0-9]+')"

function usage {
    echo -en "${YELLOW}"
    more << EOF
Usage: bash $__file__ [option] argv

-h, --help                display how to use this scripts.
-v, --version             display the $__file__ version.
-r, --run                 leverage Vagrant run to start virtual machine. (default run mode: $run_mode)
-m, --men-core            specify the VM's memory size. (default: $(( $men_num / 1024 )) GB)
-vm, --vm-name            specify Virtualbox create VM's folder.
-H, --hostname            specify VM's host name.
-p, --ssh-forward         specify VM's host ssh port forwarding.
-s, --size                specify VM's disk size. (default: $disksize_default)
-psd, --password          specify the MacOS user's password.
--disable-guimode         disable the VM's GUI mode. (default: $gui_mode)

EOF
    echo -en "${NC1}"
    return 0
}

function checknetwork
{
    local count=0
    local proxy='proxy.sin.sap.corp:8080'
    local network=$1

    while true
    do
        if [ "$(command -v curl)" == "" ]; then
            ping $network -c 1 -q > /dev/null 2>&1
        else
            curl $network -c 1 -q > /dev/null 2>&1
        fi
        case $? in
            0)
                printf "${BLUE} %s ${NC1} \n" "network connect success ..."
                return 0
                ;;
            *)
                export {https,http}_proxy=$proxy

                # check fail count
                if [ $count -ge 4 ]; then
                    printf "${RED} %s ${NC1} \n" "network still disconnection ..."
                    exit 1
                fi
                ;;
        esac
        count=$(( count + 1 ))
    done
}

function preReqPkg {

    local basic_pkgs=(
        'wget'
        'curl'
        'git-lfs'
        'node'
        'docker'
        'virtualbox'
        'vagrant'
    )

    if [ "$(command -v brew)" == "" ]; then
        printf "%-40s [${BLUE} %s ${NC1}]\n" \
               " * installation " \
               " brew ... "
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        brew update
    fi

    if [ $? -ne 0 ]; then
        printf "%-40s [${RED} %s ${NC1}]\n" \
               " * installation " \
               " brew fail ... "
        exit 1
    fi

    for p in "${basic_pkgs[@]}"
    do
        case "$p" in
            "docker"|"virtualbox"|"vagrant")
                local flag="--cask"
                ;;
            *)
                local flag=""
                ;;
        esac
        if [ "$(command -v $p)" == "" ]; then
            printf "%-40s [${BLUE} %s ${NC1}]\n" \
                   " * installation " \
                   " --> ${p} "
            echo "$passwd" | brew install ${flag} $p
            if [ "$p" == "git-lfs" ]; then
                git lfs install
            fi
        fi
    done
}

function installplug
{
    # ps aux | grep -v grep | grep -i vbox      // inspect the vboxmange process whether exist.
    local vbx_version=$(vboxmanage --version | cut -c 1-3)
    local vbguest_version='0.21'
    local plugin_list=(vagrant-disksize
                       vagrant-proxyconf
                       vagrant-vbguest)
                       # vagrant-vbox-snapshot
    for plug in "${plugin_list[@]}"
    do
        if [ $(vagrant plugin list | grep -ci $plug) -ne 0 ]; then
            printf "%-40s [${RED} %s ${NC1}]\n" \
                   " * vagrant plugin: $plug " \
                   "exist"
            continue
        else
            case "$plug" in
                "vagrant-vbguest")
                    local flag="--plugin-version 0.21"
                    ;;
                *)
                    local flag=""
                    ;;
            esac
            vagrant plugin install $plug $flag \
            --plugin-clean-sources \
            --plugin-source http://rubygems.org
        fi
    done
    echo -en "${YELLOW}"
    more << EOF
Show vagrant information
===========================================================================
    - Run time: $(date '+[%F %T]')
    - Vboxmanage version: $vbx_version
    - Vagrant version: $(vagrant --version | awk '{print $2}')
    - Vagrant plugin list:

$(vagrant plugin list)
===========================================================================
EOF
    echo -en "${NC1}"
}

function config
{
    if [ ! -d $vagrant_home ]; then
        mkdir -p $vagrant_home
    fi

    if [ "$vmname" == "" ]; then
        printf "%-40s [${RED} %s ${NC1}]\n" \
                   " * required args vm name " \
                   " empty "
        exit 252
    fi

    if [ "$ssh_port" == "" ]; then
        printf "%-40s [${RED} %s ${NC1}]\n" \
                   " * required args ssh port not specify " \
                   " empty "
        exit 256

    elif [ $(echo $ssh_port | egrep -co '[0-9]+' | cut -c 1-4) -eq 0 ]; then
        printf "%-40s [${RED} %s ${NC1}]\n" \
                   " * required args ssh port format " \
                   " error "
        exit 256
    fi

    if [ "$host" == "" ]; then
        printf "%-40s [${RED} %s ${NC1}]\n" \
                   " * required args hostname " \
                   " empty "
        exit 254
    fi

    if [ ! -d ${vagrant_home}/${vmname} ]; then
        mkdir -p ${vagrant_home}/${vmname}
    else
        printf "%-40s [${RED} %s ${NC1}]\n" \
                   " * virtualbox hostname: $vmname " \
                   " already exist "
        exit 0
    fi

    if [ "$men_core" == "" ]; then
        local men_core=$men_num
    else
        local men_core=$men_core
        if [ $(echo $men_core | grep -Eco '[0-9]+') -ne 1 ] ||
           [ "$men_core" -lt "4096" ]; then
            printf "%-40s [${RED} %s ${NC1}]\n" \
                   " * invalid arguments memory size: " \
                   " $men_core "
            exit 250
        fi
    fi

    if [ "$disksize" == "" ]; then
        local disksize=$disksize_default
    else
        local disksize=$disksize
        if [ $(echo $disksize | grep -Eco '[0-9]+') -ne 1 ] ||
           [ "$disksize" -lt "50" ]; then
            printf "%-40s [${RED} %s ${NC1}]\n" \
                   " * invalid arguments disk size: " \
                   " $disksize "
            exit 257
        fi
    fi

    local ssh_port=$(echo $ssh_port | cut -c 1-4)

    if [ $(netstat -anvp tcp | awk 'NR<3 || /LISTEN/' | grep -co $ssh_port) -ne 0 ]; then
        printf "%-40s [${RED} %s ${NC1}]\n" \
               " * the port already exist and conflict: " \
               " $ssh_port "
        exit 250
    fi

    sed -iE "s,50GB,${disksize}GB,g" $cwd/Vagrantfile
    sed -iE "s,SSH_FORWARD,$ssh_port,g" $cwd/Vagrantfile
    sed -iE "s,vb.gui\ =\ GUI_MODE,vb.gui\ =\ $gui_mode,g" $cwd/Vagrantfile
    sed -iE "s,vb.memory\ =\ \"MEM\",vb.memory\ =\ \"$men_core\",g" $cwd/Vagrantfile
    sed -iE "s,jay-vagrant,$host,g" $cwd/setup.sh

    cp -Rf . ${vagrant_home}/${vmname}

    if [ -f ${vagrant_home}/${vmname}/Vagrantfile ]; then
        if [ "$run_mode" == "True" ]; then
            cd ${vagrant_home}/${vmname}/
            vagrant up
            if [ "$(vagrant ssh-config \
                   | grep 'IdentityFile' \
                   | awk '{print $2}')" != "${vagrant_home}/${vmname}/key/id_rsa" ]; then
                sed -iE 's,# config.ssh.private_key_path = "./key/id_rsa",config.ssh.private_key_path = "./key/id_rsa",g' \
                Vagrantfile
                sed -iE 's,# config.ssh.keys_only = false,config.ssh.keys_only = false,g' Vagrantfile
                vagrant reload
            fi
            checkstatus
            cd $cwd
        fi
    fi
    return $?
}

function checkstatus
{
    case $? in
        "0")
            echo -en "${BLUE}"
            more << "EOF"

 ________ _           _        __
|_   __  (_)         (_)      [  |
  | |_ \_|_  _ .--.  __  .--.  | |--.
  |  _| [  |[ `.-. |[  |( (`\] | .-. |
 _| |_   | | | | | | | | `'.'. | | | |
|_____| [___|___||__|___|\__) )___]|__]

EOF
            echo -en "${END}"
            ;;
        "1")
            echo -en "${RED}"
            more << "EOF"
 ______     _ _
 |  ____|  (_) |
 | |__ __ _ _| |
 |  __/ _` | | |
 | | | (_| | | |
 |_|  \__,_|_|_|
EOF
            echo -en "${END}"
            ;;
    esac
}

function main
{
    checknetwork www.google.com

    preReqPkg

    installplug

    config
}

if [ "$#" -eq 0 ]; then
    printf "%-40s [${RED} %s ${NC1}]\n" \
           " Invalid arguments,   " \
           "try '-h/--help' for more information"
    exit 1
fi

while [ "$1" != "" ]
do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        -v|--version)
            printf "${YELLOW} %s ${NC1}\n" "$__file__  version: ${revision}" \
                   | sed -E s',^ ,,'g
            exit 0
            ;;
        -m|--men-core)
            shift
            men_core=$1
            ;;
        -s|--size)
            shift
            disksize=$1
            ;;
        -r|--run)
            run_mode=True
            ;;
        -p|--ssh-forward)
            shift
            ssh_port=$1
            ;;
        -psd|--password)
            shift
            passwd=$1
            ;;
        --disable-guimode)
            gui_mode=false
            ;;
        -H|--hostname)
            shift
            host=$1
            ;;
        -vm|--vm-name)
            shift
            vmname=$1
            ;;
        *)
            printf "%-40s [${RED} %s ${NC1}]\n" \
                   " Invalid arguments,   " \
                   "try '-h/--help' for more information"
            exit 1
            ;;
    esac
    shift
done

main | tee $logdir/$log_name

yes | cp -rf $logdir/$log_name ${vagrant_home}/$vmname/reports/
