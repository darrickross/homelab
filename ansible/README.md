# Homelab/Ansible

A collection of Ansible playbooks and inventories to provision and maintain a home lab environment.

## Requirements

- Ansible (>= 2.9)
- SSH access to all target hosts
- Python 3 on control machine

## Setup

1. Install Ansible on your control machine:

    ```bash
    pip install ansible
    ```

2. Verify you can SSH into each host defined in `ansible/inventory/hosts.yml`.

> [!IMPORTANT]
> If ssh into the host

## Usage

Run the main playbook against your inventory:

```bash
ansible-playbook -i ansible/inventory/hosts.yml ansible/site.yml
```

You can specify tags or limit to specific hosts as needed:

- Limit to a single host:

    ```bash
    ansible-playbook -i ansible/inventory/hosts.yml ansible/site.yml --limit=proxmox
    ```

- Run only security-related tasks:

    ```bash
    ansible-playbook -i ansible/inventory/hosts.yml ansible/site.yml --tags=security
    ```

> [!NOTE]
> I have not implemented this tags yet

## Future Upgrades

### Add tags

### Proxmox Upgrade Automation

Automate upgrading Proxmox to the latest available version via your package manager.

```yaml
- name: Gather all package facts
  package_facts:

- name: Determine current `pve-manager` package version
  set_fact:
    current_pve_version: "{{ ansible_facts.packages['pve-manager'][0].version.split('-')[0] }}"
```
