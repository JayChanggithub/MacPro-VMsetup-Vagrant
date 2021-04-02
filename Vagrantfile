# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "centos/7"
  config.disksize.size = '50GB'
  # if want via passwd to auth, enable that
  # config.ssh.password = "vagrant"
  config.vm.network "private_network", ip: "192.168.44.10"
  config.vm.network "forwarded_port", guest: 22, host: SSH_FORWARD, host_ip: "127.0.0.1", id: "ssh"
  config.ssh.forward_agent = true

  # via the private key to auth
  # config.ssh.private_key_path = "./key/id_rsa"
  # config.ssh.keys_only = false

  config.vm.box_download_insecure = true
  config.vm.box_check_update = false


  config.vm.provider "virtualbox" do |vb|

    # Display the VirtualBox GUI when booting the machine
    vb.gui = GUI_MODE

    # Customize the amount of memory on the VM:
    vb.memory = "MEM"
    vb.cpus = 4

  end

  # config.vm.synced_folder "../workspace", "/workspace"
  config.vm.provision "shell", path: "setup.sh"
end