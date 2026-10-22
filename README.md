# Generic Cloud-Init VM on Proxmox VE 9

This project creates a VM from a Cloud-Init compatible cloud image on Proxmox VE 9.
It does not install Passbolt or any other application: it only prepares the operating
system, network, DNS, and SSH access.

## Prerequisites

- Terraform 1.6 or later
- Proxmox VE 9
- Image datastore with the `Import` content type enabled
- Snippets-enabled datastore and SSH access from Terraform to the Proxmox node, only
  if SSH password login or automatic guest-agent installation is enabled
- Cloud image compatible with Cloud-Init and QEMU/KVM
- Proxmox API token with the required privileges
- Local SSH public key
- Internet connectivity from the Proxmox node to the image URL

## Variables

Values shown as `required` have no default and must be provided (for example in
`terraform.tfvars`).

| Variable | Type | Default | Description |
| --- | --- | --- | --- |
| `proxmox_endpoint` | `string` | required | Proxmox VE API endpoint, for example `https://172.168.100.10:8006/`. |
| `proxmox_api_token` | `string` | required | Proxmox API token in the format `user@realm!token=secret`. Pass it via `TF_VAR_proxmox_api_token`. |
| `proxmox_insecure` | `bool` | `false` | Allow the Proxmox API's self-signed TLS certificate. Set to `true` only with untrusted certificates. |
| `proxmox_node` | `string` | required | Proxmox node where the VM is created. |
| `image_datastore` | `string` | `"local"` | Datastore used to download/import the cloud image. |
| `cloud_image_url` | `string` | required | URL of the Cloud-Init compatible cloud image. |
| `cloud_image_file_name` | `string` | required | Image file name on Proxmox. For QCOW2 images published as `.img`, use a final `.qcow2` name. |
| `cloud_image_checksum` | `string` | `null` | Optional hexadecimal image checksum, without an algorithm prefix. Requires `cloud_image_checksum_algorithm`. |
| `cloud_image_checksum_algorithm` | `string` | `null` | Checksum algorithm: `md5`, `sha1`, `sha224`, `sha256`, `sha384`, or `sha512`. Required with `cloud_image_checksum`. |
| `cloud_image_overwrite` | `bool` | `false` | If `true`, re-download the image when the remote or local size changes. If `false`, performs no checks and never replaces the existing file. |
| `cloud_image_download_timeout` | `number` | `1800` | Download timeout in seconds. |
| `vm_datastore` | `string` | required | Datastore for the VM disk, Cloud-Init, and optional EFI disk. |
| `vm_id` | `number` | required | Unique numeric VM ID. |
| `vm_hostname` | `string` | required | VM short hostname. |
| `vm_domain` | `string` | required | VM DNS/search domain. |
| `vm_description` | `string` | `"VM managed by Terraform"` | VM description. |
| `vm_tags` | `list(string)` | `["terraform"]` | Proxmox tags assigned to the VM. |
| `vm_started` | `bool` | `true` | Start the VM after creation. |
| `vm_stop_on_destroy` | `bool` | `true` | Stop the VM before destruction. |
| `vm_startup_order` | `number` | `3` | Proxmox boot order. |
| `vm_startup_up_delay` | `number` | `30` | Boot delay in seconds. |
| `vm_startup_down_delay` | `number` | `30` | Shutdown delay in seconds. |
| `vm_machine` | `string` | `"q35"` | QEMU machine type. |
| `vm_bios` | `string` | `"seabios"` | Firmware: `seabios` or `ovmf`. |
| `vm_operating_system_type` | `string` | `"l26"` | Proxmox OS type, for example `l26` for Linux. |
| `vm_cpu_cores` | `number` | `2` | Cores per socket. |
| `vm_cpu_sockets` | `number` | `1` | Number of virtual sockets. |
| `vm_cpu_type` | `string` | `"x86-64-v2-AES"` | QEMU CPU type. |
| `vm_memory_mb` | `number` | `2048` | Dedicated RAM in MB. |
| `vm_memory_balloon_mb` | `number` | `2048` | Minimum ballooning RAM in MB. Use the same value as `vm_memory_mb` to prevent dynamic ballooning. |
| `qemu_agent_enabled` | `bool` | `false` | Enable the QEMU Guest Agent on the Proxmox side. The agent must be installed in the guest; see `install_qemu_guest_agent`. |
| `qemu_agent_timeout` | `string` | `"15m"` | Maximum wait for the QEMU Guest Agent, for example `15m` or `90s`. |
| `vm_disk_size_gb` | `number` | `20` | Disk size in GB. Must not be smaller than the imported image size. |
| `vm_disk_interface` | `string` | `"virtio0"` | Disk interface, for example `virtio0` or `scsi0`. |
| `vm_disk_cache` | `string` | `"none"` | Disk cache mode, for example `none`, `writeback`, `writethrough`, `directsync`, or `unsafe`. |
| `vm_disk_iothread` | `bool` | `true` | Enable the IO thread on the disk. |
| `vm_disk_discard` | `string` | `"on"` | Discard/TRIM mode. |
| `vm_disk_ssd` | `bool` | `false` | Expose the disk as an SSD. Ignored with the `virtio` interface: use `scsi` to enable it. |
| `vm_efi_disk_enabled` | `bool` | `false` | Create an EFI disk. Must be `true` when `vm_bios` is `ovmf`. |
| `network_bridge` | `string` | required | Proxmox bridge. |
| `network_model` | `string` | `"virtio"` | Virtual network card model. |
| `network_vlan_id` | `number` | `null` | VLAN tag; `null` if the network is presented untagged to the VM. |
| `network_firewall_enabled` | `bool` | `false` | Enable the Proxmox firewall on the virtual NIC. |
| `vm_ipv4_mode` | `string` | `"static"` | IPv4 mode: `static` or `dhcp`. |
| `vm_ipv4_address` | `string` | `null` | Static IPv4 address without prefix; `null` with DHCP. |
| `vm_ipv4_prefix` | `number` | `24` | IPv4 CIDR prefix. |
| `vm_ipv4_gateway` | `string` | `null` | IPv4 gateway; `null` with DHCP. |
| `dns_servers` | `list(string)` | `[]` | VM DNS servers. |
| `vm_username` | `string` | required | Administrative user created/configured by Cloud-Init. |
| `vm_password` | `string` | `null` | Optional Cloud-Init user password. If `null`, access uses only the SSH key. Terraform stores it in plain text in the state. |
| `ssh_password_auth_enabled` | `bool` | `false` | Enable SSH password login in the guest via a Cloud-Init vendor-data snippet. Requires a snippets-enabled datastore and provider SSH access to the Proxmox node. |
| `install_qemu_guest_agent` | `bool` | `false` | Install and start the QEMU guest agent via Cloud-Init `runcmd`. Detects apt-get, dnf, yum, or pacman. Requires a snippets-enabled datastore and provider SSH access to the Proxmox node. |
| `guest_agent_package` | `string` | `"qemu-guest-agent"` | Package installed by `install_qemu_guest_agent`. The default name is available on Debian/Ubuntu, AlmaLinux, Rocky Linux, Fedora, and Arch Linux. |
| `guest_agent_service` | `string` | `"qemu-guest-agent"` | systemd service enabled by `install_qemu_guest_agent`. Override together with `guest_agent_package` for non-standard agents. |
| `snippet_datastore` | `string` | `"local"` | Datastore for the Cloud-Init vendor-data snippet. Must have the `snippets` content type enabled. Used only when `ssh_password_auth_enabled` or `install_qemu_guest_agent` is `true`. |
| `ssh_public_key` | `string` | `null` | Public SSH key contents. If set, it takes precedence over `ssh_public_key_path` and allows planning without a local file. |
| `ssh_public_key_path` | `string` | `"~/.ssh/id_ed25519.pub"` | Local path to the SSH public key, used only when `ssh_public_key` is `null`. |

`proxmox_api_token` and `vm_password` are sensitive: provide them through env vars
`TF_VAR_proxmox_api_token` and `TF_VAR_vm_password` instead of committing them.

## Setup

Set the token without saving it in Terraform files:

```bash
export TF_VAR_proxmox_api_token='terraform@pve!terraform=SECRET_TOKEN'
```

With a self-signed TLS certificate, set `proxmox_insecure = true`; the default
value is `false` and verifies the certificate.

Check the SSH key:

```bash
test -f ~/.ssh/id_ed25519.pub
```

In CI or environments without a local file, use `ssh_public_key` with the public
key contents; it takes precedence over `ssh_public_key_path`.

## User password (optional)

To set a Cloud-Init password, use `TF_VAR_vm_password`, avoiding the value in
`terraform.tfvars`:

```bash
export TF_VAR_vm_password='changeme'
```

Alternatively, if acceptable in the local file ignored by Git:

```hcl
vm_password = "changeme"
```

The password remains in plain text in the Terraform state. With `vm_password = null`,
access uses only the SSH key.

### SSH password login

`vm_password` only sets the Cloud-Init password; it does not enable SSH password
authentication. Debian and Ubuntu cloud images ship with `PasswordAuthentication no`,
so key-based login keeps working while password login is refused.

To enable password login, set:

```hcl
ssh_password_auth_enabled = true
snippet_datastore         = "local"
```

This creates a small Cloud-Init vendor-data snippet (`ssh_pwauth: true`) and attaches
it with `vendor_data_file_id`, keeping the user and password from `user_account`.
Requirements:

- `snippet_datastore` must have the `Snippets` content type enabled.
- Terraform must be able to SSH to the Proxmox node: the provider uploads snippets
  over SSH. Configure the provider `ssh` block if the defaults do not work.
- The setting applies to a new VM or after re-running Cloud-Init in the guest
  (`sudo cloud-init clean --logs && sudo reboot`).

With `vm_password = null`, enabling `ssh_password_auth_enabled` does not create a
usable password. Prefer key-based authentication and enable password login only
when needed.

## Running

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=.tfplan
terraform apply tfplan
```

## Verifying the VM

```bash
ssh debian@172.168.100.103
cloud-init status --wait
hostname --fqdn
ip -4 address
ip route
cat /etc/resolv.conf
```

## Changing distribution

The module is distribution-agnostic: it needs a Cloud-Init compatible QCOW2 image.
When switching image, change at least:

- `cloud_image_url` and `cloud_image_file_name`
- `vm_username`, matching the image's Cloud-Init default user
- `vm_bios` and `vm_efi_disk_enabled`, only for images that require UEFI
- `vm_disk_interface`, only if required by the image
- `install_qemu_guest_agent` and `guest_agent_package`, if the image does not include
  the agent

| Distribution | `vm_username` | Example `cloud_image_url` | Notes |
| --- | --- | --- | --- |
| Debian 13 | `debian` | `https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2` | Agent installed with apt. |
| Ubuntu 24.04 | `ubuntu` | `https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img` | Upstream URL ends in `.img`; set `cloud_image_file_name` to a `.qcow2` name. |
| AlmaLinux 9 | `almalinux` | `https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2` | Agent available from AppStream via dnf. |
| Rocky Linux 9 | `rocky` | `https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2` | Agent available from AppStream via dnf. |
| Arch Linux | `arch` | `https://fastly.mirror.pkgbuild.com/images/latest/Arch-Linux-x86_64-cloudimg.qcow2` | Agent is preinstalled; `install_qemu_guest_agent` enables it. |
| Fedora Cloud Base 44 | `fedora` | `https://download.fedoraproject.org/pub/fedora/linux/releases/44/Cloud/x86_64/images/Fedora-Cloud-Base-Generic-44-1.7.x86_64.qcow2` | Agent is preinstalled; `install_qemu_guest_agent` ensures it is enabled. |

`cloud_image_file_name` must be the final path component of the URL with a `.qcow2`
extension. All images above boot with the default `vm_bios = "seabios"`; use
`ovmf` plus `vm_efi_disk_enabled = true` only if your image requires UEFI.

Fedora Server's `Fedora-Server-Guest-Generic` qcow2 is a first-boot setup image and
does not include Cloud-Init, so this module cannot provision it. Use Fedora Cloud
Base for Fedora, or build a Fedora Server image with Cloud-Init.

## Image checksum

To verify the download, set the hexadecimal hash and a separate algorithm:

```hcl
cloud_image_checksum           = "<hash>"
cloud_image_checksum_algorithm = "sha256"
```

## VLAN

Use `network_vlan_id = 200` when `vmbr0` is VLAN-aware and carries VLAN 200 tagged.
Use `network_vlan_id = null` when `vmbr0` already presents the correct network
untagged to the VM.

## QEMU Guest Agent

`qemu_agent_enabled` only enables the agent on the Proxmox side; the agent must also
be installed and running in the guest. Most cloud images do not include it by default;
Arch Linux and Fedora Cloud Base are exceptions.

For a new VM, let Cloud-Init install it:

```hcl
install_qemu_guest_agent = true
qemu_agent_enabled       = true
snippet_datastore        = "local"
```

Cloud-Init runs a small installer on first boot that detects `apt-get`, `dnf`, `yum`,
or `pacman`, then starts `qemu-guest-agent`. Override `guest_agent_package` and
`guest_agent_service` if the image uses a different package or service name. The
provider waits up to `qemu_agent_timeout` for the agent. If the installation takes
longer than the timeout, the apply still completes with a warning and the IP
addresses are populated on a later refresh.

For an existing VM, install the agent manually with the image's package manager:

```bash
# Debian / Ubuntu
sudo apt update && sudo apt install -y qemu-guest-agent

# AlmaLinux / Rocky Linux / Fedora
sudo dnf install -y qemu-guest-agent

# Arch Linux
sudo pacman -Syu --needed qemu-guest-agent
```

Then enable it:

```bash
sudo systemctl enable --now qemu-guest-agent
```

then set:

```hcl
qemu_agent_enabled = true
```

and stop/start the VM so the virtual hardware is recreated with the agent channel:

```bash
qm stop 201
qm start 201
```

A guest reboot is not enough when the agent was enabled after the VM had started.
Changing `install_qemu_guest_agent` on an existing VM does not re-run Cloud-Init;
install manually or recreate the VM.

## Limitations

The module handles already-installed cloud disks, not installation ISOs. ISOs require
a separate flow with a blank disk, CD-ROM, and manual or unattended installation.
