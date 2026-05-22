terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.7.0"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "ubuntu_image" {
  name   = "ubuntu-24.04-base.qcow2"
  pool   = "default"
  source = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  format = "qcow2"
}

resource "libvirt_network" "lab4_network" {
  name      = "lab4_network"
  mode      = "nat"
  domain    = "lab4.local"
  addresses = ["10.10.10.0/24"]
  dhcp {
    enabled = true
  }
}

resource "libvirt_cloudinit_disk" "common_db" {
  name      = "commoninit_db.iso"
  user_data = templatefile("${path.module}/cloud_init.cfg", {
    hostname = "db", ssh_key = file(var.ssh_key_path)
  })
}

resource "libvirt_volume" "db_disk" {
  name           = "db_disk.qcow2"
  base_volume_id = libvirt_volume.ubuntu_image.id
  size           = 10737418240
}

resource "libvirt_domain" "db" {
  name      = "db"
  memory    = "1024"
  vcpu      = 1
  cloudinit = libvirt_cloudinit_disk.common_db.id
  network_interface {
    network_id     = libvirt_network.lab4_network.id
    hostname       = "db"
    mac            = "52:54:00:02:ed:59"
    addresses      = ["10.10.10.10"]
    wait_for_lease = true
  }
  disk {
    volume_id = libvirt_volume.db_disk.id
  }
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}

resource "libvirt_cloudinit_disk" "common_worker" {
  name      = "commoninit_worker.iso"
  user_data = templatefile("${path.module}/cloud_init.cfg", {
    hostname = "worker", ssh_key = file(var.ssh_key_path)
  })
}

resource "libvirt_volume" "worker_disk" {
  name           = "worker_disk.qcow2"
  base_volume_id = libvirt_volume.ubuntu_image.id
  size           = 10737418240
}

resource "libvirt_domain" "worker" {
  name      = "worker"
  memory    = "1024"
  vcpu      = 1
  cloudinit = libvirt_cloudinit_disk.common_worker.id
  network_interface {
    network_id     = libvirt_network.lab4_network.id
    hostname       = "worker"
    mac            = "52:54:00:de:d5:8c"
    addresses      = ["10.10.10.20"]
    wait_for_lease = true
  }
  disk {
    volume_id = libvirt_volume.worker_disk.id
  }
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}

resource "local_file" "ansible_inventory" {
  content = <<EOT
[db_nodes]
db_server ansible_host=10.10.10.61

[worker_nodes]
worker_server ansible_host=10.10.10.254

[all:vars]
ansible_user=ansible
ansible_ssh_pass=12345678
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes'
EOT
  filename = "${path.module}/ansible_inventory"
}