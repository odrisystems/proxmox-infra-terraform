data "template_file" "private_ssh_key" {
  template = file("${path.module}/files/id_rsa")
  vars = {
    priv_ssh_key = var.private_ssh_key
  }
}
resource "local_file" "private_ssh_key" {
  content  = data.template_file.private_ssh_key.rendered
  filename = "${path.module}/files/id_rsa.priv_key"
}


data "template_file" "public_ssh_key" {
  template = file("${path.module}/files/id_rsa.pub")
  vars = {
    public_ssh_key = var.public_ssh_key
  }
}
resource "local_file" "public_ssh_key" {
  content  = data.template_file.public_ssh_key.rendered
  filename = "${path.module}/files/id_rsa.pub_key"
}


resource "proxmox_cloud_init_disk" "ci" {
  name     = local.workspace["cloud-init-disk-name"]
  pve_node = var.proxmox_host
  storage  = "local"

  meta_data = yamlencode({
    instance_id    = sha1(local.workspace["cloud-init-disk-name"])
    local-hostname = local.workspace["cloud-init-disk-name"]
  })

  user_data = templatefile("${path.module}/files/cloud-init.yaml", {
    hostname    = var.hostname_host_1
    passwd      = var.user_passwd
    ssh_pub_key = var.public_ssh_key
    ip_address  = var.ip_address
    gateway     = var.gateway

  })
}

resource "proxmox_vm_qemu" "kubernetes" {
  depends_on  = [null_resource.ubuntu-template]
  count       = 1
  name        = var.hostname_host_1
  target_node = var.proxmox_host
  onboot      = true
  clone       = "ubuntu-cloud-template"
  vmid        = local.workspace["vmid"]
  agent       = 1
  os_type     = "cloud-init"
  cores       = 4
  sockets     = 1
  cpu         = "host"
  memory      = local.workspace["memory"]
  scsihw      = "virtio-scsi-pci"
  bootdisk    = "scsi0"
  skip_ipv6   = true
  disks {
    scsi {
      scsi0 {
        disk {
          size     = 40
          storage  = "local-lvm"
          iothread = false
        }
      }
      scsi1 {
        cdrom {
          iso = "local:${proxmox_cloud_init_disk.ci.id}"
        }
      }
    }
  }

  network {
    model    = "virtio"
    firewall = false
    bridge   = "vmbr0"
  }

  lifecycle {
    ignore_changes = [
      network,
    ]
  }

  connection {
    type     = "ssh"
    user     = "k8s"
    password = var.pm_password
    host     = var.host_1
    timeout  = 10
  }

  provisioner "file" {
    source      = "files/id_rsa.priv_key"
    destination = "/tmp/id_rsa.priv_key"
  }

  # provisioner "file" {
  #   source      = "files/id_rsa.pub_key"
  #   destination = "/tmp/id_rsa.pub_key"
  # }

  # provisioner "file" {
  #   source      = "files/filebeat.yml"
  #   destination = "/tmp/filebeat.yml"
  # }

  # provisioner "file" {
  #   source      = "files/install_filebeat.sh"
  #   destination = "/tmp/install_filebeat.sh"
  # }

  provisioner "remote-exec" {
    inline = [
      "sleep 1m",
      # "cd /tmp && sudo bash install_filebeat.sh",
      "sudo apt install unzip zip -y",
      "sudo apt install zip -y",
      "sudo apt install sshpass -y",
      "sudo apt install jq -y",
      "wget https://releases.hashicorp.com/terraform/1.12.2/terraform_1.12.2_linux_amd64.zip",
      "unzip -o terraform_1.12.2_linux_amd64.zip", # Add -o to force overwrite
      "rm terraform_1.12.2_linux_amd64.zip",
      "sudo mv terraform /usr/local/bin/",
      "base64 -d /tmp/id_rsa.priv_key > /tmp/id_rsa",
      "sudo mv /tmp/id_rsa ~/.ssh/id_rsa",
      "sudo mv /tmp/id_rsa.pub_key ~/.ssh/id_rsa.pub",
      "sudo echo \"StrictHostKeyChecking no\" >> ~/.ssh/config",
      "sudo cat  ~/.ssh/id_rsa.pub >> ~/.ssh/known_hosts",
      "sudo chmod 0400 ~/.ssh/id_rsa",
      "sudo mkdir -p /storage",
      "sudo mkdir -p /storage/volumes",
      "sudo mkdir -p /storage/volumes/vault",


    ]
  }


}
