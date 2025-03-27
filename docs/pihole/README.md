# Pi-hole Setup Guide

This guide walks you through installing Pi-hole using the standard installer and then configuring a custom SSL certificate.

## 1. Standard Installation

Follow the official installation guide available here:
[Pi-hole Basic Install](https://docs.pi-hole.net/main/basic-install/)

Run the install command provided in the documentation to complete the Pi-hole installation.

## 2. Post Installation: Custom SSL Certificate Setup

### 2.1 Combine Certificate Files

Prepare the following files:

- **Unencrypted Private Key** (e.g., `private.pem`)
- **Server Certificate** (e.g., `certificate.pem`)
- **[OPTIONAL] Additional Certificate Chain** (e.g., `chain.pem`)

Combine them into one file. Use the following command block:

```bash
cat private.pem certificate.pem chain.pem > combined.pem
```

Then, move and rename the combined file to your Pi-hole directory:

```bash
sudo mv combined.pem /etc/pihole/bundle.pem
```

> **Note:** The certificate file can be placed anywhere as long as the Pi-hole user (`pihole`) has read access.

### 2.2 Set File Ownership and Permissions

Ensure the file is owned by the `pihole` user:

```bash
sudo chown pihole:pihole /etc/pihole/bundle.pem
```

For additional security, update the file permissions:

```bash
sudo chmod 600 /etc/pihole/bundle.pem
```

### 2.3 Update Pi-hole Configuration

Edit the configuration file located at `/etc/pihole/pihole.toml`. Find the following section:

```bash
[webserver.tls]

cert = "/etc/pihole/tls.pem"
```

Replace the certificate path with the path to your new certificate:

```bash
[webserver.tls]

cert = "/etc/pihole/bundle.pem"
```

### 2.4 Restart the Pi-hole Service

Restart the Pi-hole FTL service to apply your changes:

```bash
sudo service pihole-FTL restart
```

## 3. Additional Information

For further details, refer to the official guide on using your own certificate:
[Using Your Own Certificate](https://docs.pi-hole.net/api/tls/#using-your-own-certificate)
