# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.define :control do |control|
    control.vm.box = "bento/ubuntu-22.04"
    control.vm.network :private_network, ip: "192.168.100.2"
    control.vm.hostname = "control-node"
    control.vm.provider "virtualbox" do |v|
      v.memory = 1024
      v.cpus = 1
    end

    # Copia los archivos de terraform y puppet al control-node
    control.vm.provision "file", source: "./terraform", destination: "/home/vagrant/terraform"
    control.vm.provision "file", source: "./puppet",    destination: "/home/vagrant/puppet"
    control.vm.provision "file", source: "./Microservicios", destination: "/home/vagrant/Microservicios"

    # Instala Terraform y Puppet en el control-node
    control.vm.provision "shell", inline: <<-SHELL
      set -e

      # Terraform
      apt-get update -y
      apt-get install -y gnupg software-properties-common curl unzip

      curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor \
        -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

      echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
        https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
        | tee /etc/apt/sources.list.d/hashicorp.list

      apt-get update -y
      apt-get install -y terraform

      # Puppet (bolt para aplicar manifiestos remotamente)
      wget -q https://apt.puppet.com/puppet8-release-jammy.deb
      dpkg -i puppet8-release-jammy.deb
      apt-get update -y
      apt-get install -y puppet-bolt

      echo "Terraform version: $(terraform version)"
      echo "Bolt version: $(bolt version)"
    SHELL
  end

  config.vm.define :target do |target|
  target.vm.box     = "bento/ubuntu-22.04"
  target.vm.network :private_network, ip: "192.168.100.3"
  target.vm.hostname = "vm-target"
  target.vm.provider "virtualbox" do |v|
    v.memory = 3072
    v.cpus   = 2
  end
end

  

end