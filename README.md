ＭacPro VMsetup Vagrant
=========================

![image](https://github.com/JayChanggithub/MacPro-VMsetup-Vagrant/blob/master/photo/vagrant-virtualbox.gif)

---

## Suitable Project
   - [x] **MacOs Pro**

---

## Version
`Rev: 1.0.0`

---

## Description

  - This repository is supported to build up the virtual machine of **Centos7** environments via automatically within MacOS Pro.

## Usage

  - Download project in your laptop

    ```bash
    # Download project in your laptop
    $ git clone https://github.com/JayChanggithub/MacPro-VMsetup-Vagrant.git
    $ cd ./MacPro-VMsetup-Vagrant

    # Via vagrant engine to deployment VM
    $ vagrant up
    ```

  - Via vagrant engine to deployment VM

    ```bash
    $ vagrant up
    ```

  - Parameter comparison table：

    |   **Parameter**   |                 **Description**                 |
    |:-----------------:|:-----------------------------------------------:|
    |  -m, --men-core   | specify the VM's memory size. (default: 4 GB)。   |
    |  -r, --run        | leverage Vagrant run to start virtual machine. (default run mode: False)。 |
    |  -vm, --vm-name   | specify Virtualbox create VM's folder。         |
    |  -H, --hostname   | specify VM's host name。                        |
    |  -p, --ssh-forward| specify VM's host ssh port forwarding。         |
    |  -psd, --password | specify MacPro login password                   |
    |  --disable-guimode  | disable the VM's GUI mode. (default: true)。  |
    |  -s, --size       | specify the VM's disk size. (default: 50GB)。   |



  - Ｃomplete example commandlin

    ```bash
    $ bash vagrant-setup.sh -psd $mac_password -s 50 -p 2210 -H k8s-master1 -vm k8s-master1 -r -m 4096
    ```

  - After update the **vagrantfile** type the following commandline to reload and restart virtual machine.


    ```bash
    $ vagrant reload
    ```

  - Inspect the ssh authentication methodology

    ```bash
    $ vagrant ssh-config

    ```

  - Inspect vagrant VM's state list

    ```bash
    $ vagrant global-status
    ```

  - Resize your root partition

    ```bash
    # Edit Vagrantfile by manually
    config.disksize.size = '70GB'
    ```

    ```bash
    $ fdisk /dev/sda << EOF
    d
    n
    p
    1



    w
    EOF
    $ partprobe
    ```

    ```bash
    # grow up the root partitions xfs filesystem
    $ growpart /dev/sda 1
    $ xfs_growfs /
    ```

  - Shutdown VM

    ```bash
    $ vagrant halt
    ```

  - Startup VM

    ```bash
    $ vagrant up
    ```

  - Via vagrant install VM's enable GUI mode

    - **[Setup Vagrant GUI mode](https://codingbee.net/vagrant/vagrant-enabling-a-centos-vms-gui-mode)** <br>

## Contact
##### Author: chieh-chuna.chang
##### Email: chieh-chuna.chang@sap.com
