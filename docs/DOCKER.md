# Docker Deployment Guide

This guide explains how to run TM-NmapUI using Docker. Using Docker ensures a consistent environment with all necessary dependencies (Nmap, Python, Chromium, etc.) pre-installed.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Quick Start

1. **Build and start the container:**

   ```bash
   docker-compose up -d --build
   ```

2. **Access the application:**

   Open [http://localhost:9000](http://localhost:9000) in your browser.

## Configuration Details

The Docker setup uses several important configurations to ensure Nmap functions correctly:

- **Host Networking (`network_mode: host`)**: This allows the container to share the host's network stack. Nmap needs this for ARP discovery, OS detection, and other low-level network features that don't work well over NAT.
- **Privileged Mode (`privileged: true`)**: Required for Nmap to perform raw socket operations.
- **Volume Mounting**: 
  - The current directory is mounted to `/app` in the container.
  - An anonymous volume is used for `node_modules` to prevent conflicts between host and container dependencies.

## Syncing with Fork

Because the project directory is mounted as a volume, you can continue to use Git on your host machine to sync with the original repository or push your own changes:

1. **Pull changes on the host:**

   ```bash
   git pull origin main
   ```

2. **The container will see the updated code immediately.** If `package.json` changed, you may need to rebuild to update dependencies:

   ```bash
   docker-compose up -d --build
   ```

## Troubleshooting

### Port 9000 in use
If you already have a service running on port 9000, you can change the port in `docker-compose.yml` or stop the existing service. Note that since we use `network_mode: host`, the app binds directly to the host's port.

### Permission issues
Nmap often requires root privileges. The container runs as root by default and uses `privileged: true` to handle this.

## Stopping the application

To stop and remove the container:

```bash
docker-compose down
```
