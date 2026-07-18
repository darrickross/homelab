# TODO — Security Review Follow-ups (2026-07-15)

Remaining items from a security review of this repo, grouped by priority.

Already resolved (not listed below):

- PFX password exposed on the openssl command line in `convert_pfx.sh` — fixed,
  script moved to the dotfiles repo.
- Proxmox GPG key trusted globally via deprecated `apt_key` — fixed in
  `darrickross.proxmox.enable_opensource_repos` (dedicated keyring +
  `[signed-by=...]` + https).

---

## P0 — Critical

*None found.*

## P1 — Important

### Ansible connects to hypervisors as root

- **What:** Replace direct root SSH with a dedicated automation user
  (e.g. `ansible`) using sudo/become, then set `PermitRootLogin no` on the
  hypervisors. Also consolidate the two `ansible.cfg` files — Ansible loads
  only one (the nearest), so `remote_user = ansible` in `ansible/ansible.cfg`
  is silently ignored when running from the repo root, and the inventory's
  `ansible_user: root` overrides it anyway.
- **Where:** `ansible/inventory/hosts.yml` (`ansible_user: root` on both
  hosts), `ansible/ansible.cfg`, `ansible.cfg`.
- **Why:** Root SSH on the most critical machines means any compromise of the
  key path is instant full compromise with no audit trail. A named automation
  user with sudo preserves attribution and allows disabling root login
  entirely. The Yubikey-backed key mitigates but does not remove the risk.

## P2 — Warning

### Public repo discloses hypervisor infrastructure the README says is private

- **What:** Stop committing the real inventory. Gitignore `ansible/inventory/`
  and commit a sanitized `example-inventory/` instead (same pattern already
  used for `secrets.nix` / `example-secrets.nix`).
- **Where:** `ansible/inventory/hosts.yml`,
  `ansible/inventory/host_vars/hv00-pve.sol.mw.yml`,
  `ansible/inventory/host_vars/hv01-pve.sol.mw.yml`.
- **Why:** The README states core infrastructure (hypervisors, routers, etc.)
  will not be published, but the committed inventory names both Proxmox
  hypervisors, the internal domain (`sol.mw`), the p2p link addressing, and
  the access path (root SSH + Yubikey key). Not directly exploitable, but
  it is free reconnaissance material and contradicts the stated policy.
  Note: files remain in git history after removal; scrubbing history is a
  separate decision.

## P3 — Low

### `proxy_ssl_verify off` in the Proxmox nginx proxy

- **What:** Add a warning comment (or a conditional) so upstream TLS
  verification is only skipped for loopback upstreams. If the upstream is
  ever pointed at a remote host, enable `proxy_ssl_verify on` with
  `proxy_ssl_trusted_certificate`.
- **Where:**
  `ansible/collections/ansible_collections/darrickross/proxmox/roles/nginx_proxy/templates/proxmox.conf.j2`
  (line with `proxy_ssl_verify off`) and the upstream default in
  `.../nginx_proxy/defaults/main.yml` (`nginx_proxy_proxmox_upstream`).
- **Why:** Harmless today because the default upstream is `127.0.0.1:8006`,
  but the variable is overridable — pointing it at a remote host would
  silently proxy the Proxmox admin UI over unverified TLS (MITM-able).
  A comment at the override point prevents the future foot-gun.

### Nix "secrets" end up world-readable in the Nix store

- **What:** Document that `secrets.nix` must never hold real credentials, or
  adopt agenix / sops-nix before any credential (e.g. a Steam beta password)
  enters that file.
- **Where:** `game-server-satisfactory/nix-configs/secrets.nix` (imported by
  `system-configs.nix` and `satisfactory.nix`); the risk concretely applies
  to `steam-game-beta-password` in `satisfactory.nix`.
- **Why:** Anything imported into the NixOS configuration is copied into
  `/nix/store`, which is world-readable, and would also appear in the
  generated systemd unit. Today the file only holds IPs/ports (fine), but the
  pattern will leak the first real secret placed in it.

## P4 — Nit

### Game-server systemd units lack sandboxing/hardening directives

- **What:** Add hardening directives to both Satisfactory service units:
  `NoNewPrivileges=true`, `ProtectSystem=strict` (with `ReadWritePaths=` for
  the install, log, and home dirs), `ProtectHome=` tuned to the save
  location, `RestrictSUIDSGID=true`; add `PrivateTmp=true` to the Ubuntu
  unit (the NixOS unit already has it).
- **Where:**
  `game-server-satisfactory/nix-configs/satisfactory.nix` (serviceConfig) and
  `game-server-satisfactory/simple-ubuntu-configs/etc/systemd/system/satisfactory.service`.
- **Why:** The service runs third-party binaries fetched by steamcmd. It
  already runs as a dedicated user (good); sandboxing directives cheaply
  limit blast radius if the server binary is ever compromised.

### Logrotate config uses trailing comments (functional bug, not security)

- **What:** Move inline comments (`daily       # Check daily`) onto their own
  lines.
- **Where:**
  `game-server-satisfactory/simple-ubuntu-configs/etc/logrotate.d/satisfactory.conf`.
- **Why:** logrotate rejects trailing text after directives, so this config
  likely errors on every rotation run and the logs never rotate.
