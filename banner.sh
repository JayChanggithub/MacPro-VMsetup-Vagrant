#!/bin/bash
RED='\033[1;31m'
BLUE='\033[1;34m'
END='\033[0m'
echo -en "${BLUE}"
more << "EOF"
███████╗ █████╗ ██████╗     ██████╗ ███████╗██╗   ██╗ ██████╗ ██████╗ ███████╗
██╔════╝██╔══██╗██╔══██╗    ██╔══██╗██╔════╝██║   ██║██╔═══██╗██╔══██╗██╔════╝
███████╗███████║██████╔╝    ██║  ██║█████╗  ██║   ██║██║   ██║██████╔╝███████╗
╚════██║██╔══██║██╔═══╝     ██║  ██║██╔══╝  ╚██╗ ██╔╝██║   ██║██╔═══╝ ╚════██║
███████║██║  ██║██║         ██████╔╝███████╗ ╚████╔╝ ╚██████╔╝██║     ███████║
╚══════╝╚═╝  ╚═╝╚═╝         ╚═════╝ ╚══════╝  ╚═══╝   ╚═════╝ ╚═╝     ╚══════╝
EOF
echo -en "${END}"
echo -en "${RED}"
more << "EOF"
WARNING:
    1. This VMs is use vagrant build centos enviroments for SAP DevOps, Every changed
       will be vagrant reload.
    2. Please remember to setup the git config when you start use git command to operate the repository.
EOF
echo -en "${END}"
echo -en "${RED}"
more << "EOF"
Service:
    - Running service on this operation system:
      1. docker
      3. git
      4. Ansible
      5. golang
Package:
    - Below listed packages are installed in the image:
      1. python3.9
      2. golang
      4. gcc, ftp, curl, wget, vim, tree, openssh-server
EOF
echo -en "${END}"