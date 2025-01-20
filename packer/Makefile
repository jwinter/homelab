default:
	@packer build -var password=${PROXMOX_PW} packer.pkr.hcl

build-log:
	@PACKER_LOG=1 packer build -var password=${PROXMOX_PW} packer.pkr.hcl
