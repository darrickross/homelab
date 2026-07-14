# AGENTS.md — Agent guidance for this homelab repo

## What this repo is

A **public** infrastructure-as-code repo for a personal homelab. It contains
Ansible automation for Proxmox hypervisors, NixOS/Ubuntu configs for a
Satisfactory game server, and supporting documentation. Core infrastructure
(routers, firewalls, hypervisor internals beyond what's here, domain
controllers) is deliberately **not** published — do not add configs or details
for those systems.

## Repo layout

| Path                        | Purpose                                                                                    |
| --------------------------- | ------------------------------------------------------------------------------------------ |
| `ansible/site.yml`          | Main playbook — configures the Proxmox hypervisors end to end                              |
| `ansible/inventory/`        | `hosts.yml` (group `hypervisors_proxmox`) plus per-host vars in `host_vars/`               |
| `ansible/collections/`      | In-repo custom collections: `darrickross.proxmox` and `darrickross.debian`                 |
| `game-server-satisfactory/` | Satisfactory dedicated server — `nix-configs/` (preferred) and `simple-ubuntu-configs/`    |
| `docs/`                     | Guides: certificate management (Windows CA), NixOS notes, pihole, full command output logs |
| `scripts/`                  | Helper scripts (e.g. `certificate-management/convert_pfx.sh`)                              |

Two `ansible.cfg` files exist and both matter: the root one pins the inventory
path (so `ansible-playbook ansible/site.yml` works from the repo root), and
`ansible/ansible.cfg` sets `collections_paths = ./collections:...` so the
in-repo collections resolve. Run ansible commands from the repo root.

## Ansible conventions

- Roles live inside the in-repo collections under
  `ansible/collections/ansible_collections/darrickross/<collection>/roles/`.
  New reusable roles go there (`debian` for generic Debian-family work,
  `proxmox` for Proxmox-specific work), not in a top-level `roles/` dir —
  `ansible/roles/` exists but is vestigial.
- Roles follow the standard shape: `defaults/main.yml` for tunables (prefixed
  with the role name, e.g. `networking_p2p0_mtu`, `nginx_proxy_ssl_certificate`),
  `handlers/`, `meta/`, `tasks/`, `templates/`.
- `site.yml` starts with a **serial SSH warm-up play**. This is load-bearing:
  the SSH key is a YubiKey (`~/.ssh/yubikey_sk`, `ed25519-sk`) that can service
  only one auth request at a time, so multiplexed connections are established
  one host at a time before parallel plays run. Do not remove it or make it
  parallel.
- Service changes should be fail-safe like the `nginx_proxy` role: template
  with `backup: true`, `nginx -t` before reload, `rescue:` restores the backup.
  Recent work also made nginx wait (systemd path unit + `ExecStartPre` loop)
  for the Proxmox-managed cert to exist before starting — preserve that
  ordering when touching either side.
- Lint before committing: `yamllint` (config `.yamllint.yml`, line-length
  disabled) and `ansible-lint` (config `.ansible-lint`, only
  `galaxy[no-changelog]` skipped). VS Code settings in `.vscode/` expect the
  Red Hat Ansible extension.

## Credentials and secrets

This repo is public and contains **no secrets** — keep it that way. The
secrets machinery lives in the sibling `dotfiles` repo (see
`../dotfiles/AGENTS.md`), which manages this machine via Nix Home Manager:

- Application secrets live in **Bitwarden Secrets Manager (BWS)**, never on
  disk and never in this repo. Usage pattern (once per shell):
  `bws-load-local-machine-credential` to export `BWS_ACCESS_TOKEN` (decrypted
  from a sops+age+YubiKey encrypted file), then `bws run -- <command>` to
  inject secrets as env vars named after their BWS **Key**
  (`SCREAMING_SNAKE_CASE`). List what's available with
  `bws-check-available-secrets`.
- If a playbook or script here needs a secret, read it from an environment
  variable and document that it's injected via `bws run -- ansible-playbook …`.
  Never hardcode secret values, write them to tracked files, `/tmp`, or shell
  rc files, and never echo them into logs/output.
- SSH and GPG are YubiKey-backed through Windows-side wrappers (this is WSL2;
  the key is not passed through via USB). Expect touch/PIN prompts during
  ansible runs; don't "fix" auth by generating soft keys.
- The game-server pattern for host-local secrets: `example-secrets.nix` is the
  committed template; the real `secrets.nix` is created on the target host and
  is gitignored (`nix-configs/.gitignore`). Follow the same
  template-plus-gitignore pattern for anything new that holds real IPs/values
  you don't want published.
- `.gitignore` already excludes Terraform state/`*.tfvars`, `.env*`, and
  Packer artifacts in anticipation of future IaC — keep those out of git.

## Tooling on this machine

Packages and CLIs (ansible, bws, sops, etc.) are managed declaratively by Home
Manager in the `dotfiles` repo. Do not `pip install`, `apt install`, or
`nix-env -i` tooling here — add it to the appropriate module in
`../dotfiles/.config/home-manager/` and run `hms`. (The `pip install ansible`
step in `ansible/README.md` is generic advice for other users of this public
repo, not for this machine.)

## Documentation conventions

- Every directory has a `README.md` that begins with a
  "0 - Relative Folder Structure" section linking parent/children with a
  `<------------ ***YOU ARE HERE***` marker, and longer docs use numbered
  headings with a Table of Contents. Match this when adding or moving docs,
  and update the affected folder-structure lists (including the root
  `README.md`).
- LF line endings only.
- Markdown tables written for humans should have aligned pipe columns
  (`../dotfiles/scripts/markdown/fix-tables.py` automates this).
- Docs favor full worked examples — exact commands, expected output blocks,
  and GitHub-style `> [!NOTE]`/`> [!WARNING]` admonitions. Long raw logs go in
  `docs/full-output-examples/`.
