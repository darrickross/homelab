# Homelab/ansible

TODO Clean up this README

Set up:

Install ansible

Set up Ansible User on Hosts:

```bash
useradd -m -s /bin/bash ansible
passwd -l ansible
usermod -aG sudo ansible
install -o ansible -g ansible -m 700 -d /home/ansible/.ssh
echo 'sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIKn9JcmQKEx2sVH7H4shJsrbQocxDF99Xn7P4fFJrDy3AAAABHNzaDo= Yubikey #0 20250221' > /home/ansible/.ssh/authorized_keys
chown ansible:ansible /home/ansible/.ssh/authorized_keys
chmod 600 /home/ansible/.ssh/authorized_keys
```
