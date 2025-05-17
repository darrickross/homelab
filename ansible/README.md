# Homelab/ansible

TODO:

- Clean up this README

Set up:

Install ansible

Run:

```bash
ansible-playbook -i ansible/inventory/hosts.yml ansible/site.yml
```

Future upgrades:

proxmox-upgrade:

Automate the upgrade to use the latest version the package manager sees

```ansible
- name: Gather all package facts
  package_facts:

- name: Determine pve-manager version
  set_fact:
    current_pve_version: "{{ ansible_facts.packages['pve-manager'][0].version.split('-')[0] }}"
```
