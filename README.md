# VM Cloud-Init generica su Proxmox VE 9

Questo progetto crea una VM da una cloud image compatibile Cloud-Init su Proxmox VE 9.
Non installa Passbolt o altri applicativi: prepara soltanto il sistema operativo, la rete, il DNS e l'accesso SSH.

## Prerequisiti

- Terraform 1.6 o successivo
- Proxmox VE 9
- Datastore immagini con content type `Import` abilitato
- Cloud image compatibile Cloud-Init e QEMU/KVM
- API token Proxmox con i privilegi necessari
- Chiave SSH pubblica locale
- Connettivita Internet del nodo Proxmox verso l'URL dell'immagine

## Preparazione

Impostare il token senza salvarlo nei file Terraform:

```bash
export TF_VAR_proxmox_api_token='terraform@pve!terraform=SECRET_TOKEN'
```

Con certificato TLS self-signed impostare `proxmox_insecure = true`; il valore
predefinito e `false` e verifica il certificato.

Verificare la chiave SSH:

```bash
test -f ~/.ssh/id_ed25519.pub
```

In CI o ambienti senza file locale usare `ssh_public_key` con il contenuto della
chiave pubblica; ha precedenza su `ssh_public_key_path`.

## Esecuzione

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

## Verifica della VM

```bash
ssh debian@172.168.100.103
cloud-init status --wait
hostname --fqdn
ip -4 address
ip route
cat /etc/resolv.conf
```

## Cambiare distribuzione

Per usare un'altra cloud image modificare almeno:

- `cloud_image_url`
- `cloud_image_file_name`
- `vm_username`
- `vm_bios` ed `vm_efi_disk_enabled`, se l'immagine richiede UEFI
- `vm_disk_interface`, se richiesto dall'immagine
- `vm_disk_ssd`, se serve emulazione SSD (non supportata con `virtio`)
- `qemu_agent_enabled`, in base alla presenza dell'agent nel guest

Esempio Ubuntu 24.04:

```hcl
cloud_image_url       = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
cloud_image_file_name = "ubuntu-24.04-noble-server-cloudimg-amd64.qcow2"
vm_username           = "ubuntu"
```

## Checksum immagine

Per verificare il download impostare hash esadecimale e algoritmo separato:

```hcl
cloud_image_checksum           = "<hash>"
cloud_image_checksum_algorithm = "sha256"
```

## VLAN

Usare `network_vlan_id = 200` quando `vmbr0` e VLAN-aware e trasporta la VLAN 200 tagged.
Usare `network_vlan_id = null` quando `vmbr0` presenta gia la rete corretta untagged alla VM.

## QEMU Guest Agent

Il valore predefinito e `false`. Dopo aver installato e avviato l'agent nel guest:

```bash
sudo apt update
sudo apt install -y qemu-guest-agent
sudo systemctl enable --now qemu-guest-agent
```

si puo impostare:

```hcl
qemu_agent_enabled = true
```

## Limiti

Il modulo gestisce dischi cloud gia installati, non ISO di installazione. Le ISO richiedono un flusso separato con disco vuoto, CD-ROM e installazione manuale o unattended.
