packer {
  required_plugins {
    name = {
      version = "1.2.1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "password" {
  type    = string
  default = "supersecret"
}

variable "username" {
  type    = string
  default = "root@pam"
}

build {
  sources = ["source.proxmox-iso.rocky-kickstart"]

  # this is copy/pasted; looks like it's trying to clean up ssh before saving the image
  provisioner "shell" {
    inline = ["yum install -y cloud-init qemu-guest-agent cloud-utils-growpart gdisk",
      "systemctl enable qemu-guest-agent",
      "shred -u /etc/ssh/*_key /etc/ssh/*_key.pub",
      "rm -f /var/run/utmp",
      ">/var/log/lastlog", #truncate these files (`>file` truncates a file)
      ">/var/log/wtmp",
      ">/var/log/btmp",
      "rm -rf /tmp/* /var/tmp/*",
      "unset HISTFILE; rm -rf /home/*/.*history /root/.*history",
      "rm -f /root/*ks",
      # "passwd -d root",
      # "passwd -l root",
      "sudo truncate -s 0 /etc/machine-id",
      #"rm -f /etc/ssh/ssh_config.d/allow-root-ssh.conf"
    ]
  }

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
    provisioner "file" {
        source = "config/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }
    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
    provisioner "shell" {
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }  
}

source "proxmox-iso" "rocky-kickstart" {
  boot_command = [
    "<tab> text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter><wait>"
    #"<tab> text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter><wait>"
  ]
  boot_wait    = "10s"
  disks {
    disk_size         = "8G"
    storage_pool      = "local-lvm"
    type              = "scsi"
    format            = "raw"
  }
  efi_config {
    efi_storage_pool  = "local-lvm"
    efi_type          = "4m"
    pre_enrolled_keys = true
  }
  http_directory           = "config"
  insecure_skip_tls_verify = true
  boot_iso {
    iso_file                 = "local:iso/Rocky-9.5-x86_64-minimal.iso"
  }
  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }
  qemu_agent = true

  cpu_type = "host"
  memory="2048"
  scsi_controller ="virtio-scsi-single"
  username             = "${var.username}"
  password             = "${var.password}"
  node                 = "proxmox"
  proxmox_url          = "https://10.0.0.200:8006/api2/json"
  ssh_username         = "root"
  ssh_password         = "securepassword"
  ssh_timeout          = "15m"

  cloud_init = true
  cloud_init_storage_pool = "local-lvm"
  
  template_description = "Rocky 9, generated on ${timestamp()}"
  template_name        = "rocky-9-${formatdate("YYYY-MM-DD-hh-mm-ss", timestamp())}"
}
