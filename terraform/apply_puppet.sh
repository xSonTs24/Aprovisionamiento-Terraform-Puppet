#!/bin/bash
set -e

# Obtiene la IP de vm-target desde el output de Terraform
VM_IP=$(terraform output -raw vm_target_ip)
echo "Aplicando Puppet en $VM_IP..."

# Copia los modulos puppet a vm-target
rsync -av -e "ssh -i /home/vagrant/.ssh/vm_target_key -o StrictHostKeyChecking=no" \
  /home/vagrant/puppet/ vagrant@$VM_IP:/home/vagrant/puppet/

# Aplica el manifiesto con puppet apply
ssh -i /home/vagrant/.ssh/vm_target_key \
    -o StrictHostKeyChecking=no \
    vagrant@$VM_IP \
    "sudo apt-get install -y puppet && sudo puppet apply /home/vagrant/puppet/manifests/site.pp --modulepath=/home/vagrant/puppet/modules"

echo "Puppet aplicado exitosamente en $VM_IP"