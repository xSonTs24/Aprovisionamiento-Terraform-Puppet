terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

variable "vm_target_ip" {
  default = "192.168.100.3"
}

# Par de llaves SSH
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "/home/vagrant/.ssh/vm_target_key"
  file_permission = "0600"
}

resource "local_file" "public_key" {
  content  = tls_private_key.ssh_key.public_key_openssh
  filename = "/home/vagrant/.ssh/vm_target_key.pub"
}

# Inyecta la llave publica en vm-target
resource "null_resource" "inject_key" {
  depends_on = [local_file.private_key]

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ~/.ssh",
      "echo '${tls_private_key.ssh_key.public_key_openssh}' >> ~/.ssh/authorized_keys",
      "chmod 600 ~/.ssh/authorized_keys"
    ]

    connection {
      type     = "ssh"
      user     = "vagrant"
      password = "vagrant"
      host     = var.vm_target_ip
    }
  }
}

# Copia los archivos de puppet y microservicios a vm-target
resource "null_resource" "copy_files" {
  depends_on = [null_resource.inject_key]

  provisioner "local-exec" {
    command = "rsync -av -e 'ssh -i /home/vagrant/.ssh/vm_target_key -o StrictHostKeyChecking=no' /home/vagrant/puppet/ vagrant@${var.vm_target_ip}:/home/vagrant/puppet/"
  }

  provisioner "local-exec" {
    command = "rsync -av -e 'ssh -i /home/vagrant/.ssh/vm_target_key -o StrictHostKeyChecking=no' /home/vagrant/Microservicios/ vagrant@${var.vm_target_ip}:/home/vagrant/Microservicios/"
  }
}

# Aplica Puppet en vm-target
resource "null_resource" "apply_puppet" {
  depends_on = [null_resource.copy_files]

  provisioner "local-exec" {
    command = "ssh -i /home/vagrant/.ssh/vm_target_key -o StrictHostKeyChecking=no vagrant@${var.vm_target_ip} 'sudo apt-get update -y && wget -q https://apt.puppet.com/puppet7-release-jammy.deb && sudo dpkg -i puppet7-release-jammy.deb && sudo apt-get update -y && sudo apt-get install -y puppet-agent && sudo /opt/puppetlabs/bin/puppet apply /home/vagrant/puppet/manifests/site.pp --modulepath=/home/vagrant/puppet/modules'"
  }
}

output "vm_target_ip" {
  value = var.vm_target_ip
}