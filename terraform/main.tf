terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc5"
    }
  }
}

variable password {
  type = string
}

provider "proxmox" {
  pm_api_url      = "https://10.0.0.200:8006/api2/json"
  pm_user         = "root@pam"
  pm_password     = var.password
  pm_tls_insecure = true
}

variable "vm_count" {
  default = 3
}

resource "proxmox_vm_qemu" "vm" {
  count       = var.vm_count
  name        = "rke2-rocky-vm-${count.index + 1}"
  target_node = "proxmox"
  clone       = "rocky-9-2025-01-25-23-03-09"
  agent = 1
  
  os_type     = "cloud-init"
  cores       = 2
  memory      = 4096
  sockets     = 1
  scsihw      = "virtio-scsi-pci"

  disks {
    scsi {
      scsi0 {
        disk {
          size     = 20
          storage  = "local-lvm"
        }
      }
    }
    # ide {
    #   ide3 {
    #     cloudinit {
    #       disk {
    #         storage = "local-lvm"
    #       }
    #     }
    #   }
    # }
  }

  network {
    id = 0
    model  = "virtio"
    bridge = "vmbr0"
    tag = 256
  }

  
  lifecycle {
    ignore_changes = [
      network,  # Ignore network changes if dynamically assigned
      disk,     # Ignore disk changes
    ]
  }
}
