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
  sources = ["source.proxmox-iso.fedora-kickstart"]
}

source "proxmox-iso" "fedora-kickstart" {
  boot_command = [
    "<tab> text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter><wait>"
    #"<tab> text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter><wait>"
  ]
  boot_wait    = "10s"
  disks {
    disk_size         = "5G"
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
  #ssh_password         = "packer"
  ssh_timeout          = "15m"
  template_description = "Fedora 29-1.2, generated on ${timestamp()}"
  template_name        = "fedora-29"
}
