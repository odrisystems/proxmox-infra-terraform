resource "null_resource" "ubuntu-template" {
  triggers = {
    key = uuid()
  }
  connection {
    type     = "ssh"
    user     = "root"
    password = data.vault_kv_secret_v2.proxmox.data["password"]
    host     = data.vault_kv_secret_v2.proxmox.data["host"]
  }
  provisioner "file" {
    source      = "files/ubuntu_20_cloud_template.sh"
    destination = "/tmp/ubuntu_20_cloud_template.sh"
  }
  provisioner "file" {
    source      = "files/resolv.conf"
    destination = "/etc/resolv.conf"
  }

  provisioner "file" {
    source      = "files/pve-enterprise.list"
    destination = "/etc/apt/sources.list.d/pve-enterprise.list"
  }
  provisioner "file" {
    source      = "files/ceph.list"
    destination = "/etc/apt/sources.list.d/ceph.list"
  }
  provisioner "remote-exec" {
    inline = [
      "apt update -y",
      "chmod +x /tmp/ubuntu_20_cloud_template.sh",
      "/tmp/ubuntu_20_cloud_template.sh",
      "sleep 10s"

    ]
  }
}
