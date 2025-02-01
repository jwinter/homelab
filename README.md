### Homelab Infrastructure Code

Currently standing up a kubernetes cluster on a Proxmox hypervisor.

[VM Templates](https://pve.proxmox.com/wiki/VM_Templates_and_Clones) are built with packer based on a Rocky 9 VM image.

Terraform stands up 3 VMs cloned off of that VM template built by packer.
