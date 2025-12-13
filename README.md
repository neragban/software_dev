# Raspberry Pi Port Scanner - Docker Deployment

This directory contains a multi-threaded port scanner optimized for deployment on Raspberry Pi using Docker.

## Files Overview

- `Multi-Thread Port Scanner.py` - Main Python script
- `Dockerfile` - Docker container configuration
- `docker-compose.yml` - Docker Compose configuration for easy deployment
- `requirements.txt` - Python dependencies
- `deploy.sh` - Deployment script for easy management
- `README.md` - This file

## Prerequisites

1. **Docker installed on Raspberry Pi**
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   sudo usermod -aG docker $USER
   ```

2. **Docker Compose (optional, for using docker-compose.yml)**
   ```bash
   sudo pip3 install docker-compose
   ```

## Quick Start

### Method 1: Using the deployment script (Recommended)

1. Make the script executable:
   ```bash
   chmod +x deploy.sh
   ```

2. Build and run:
   ```bash
   ./deploy.sh build
   ./deploy.sh run
   ```

### Method 2: Using Docker directly

1. Build the image:
   ```bash
   docker build -t raspberry-port-scanner .
   ```

2. Run the scanner:
   ```bash
   docker run -it --network host -v $(pwd)/results:/app/results raspberry-port-scanner
   ```

### Method 3: Using Docker Compose

1. Build and run:
   ```bash
   docker-compose up --build
   ```

2. For interactive mode:
   ```bash
   docker-compose run --rm port-scanner
   ```

## Usage Commands

### Deployment Script Commands

- `./deploy.sh build` - Build the Docker image
- `./deploy.sh run` - Run the port scanner interactively
- `./deploy.sh stop` - Stop the running container
- `./deploy.sh clean` - Remove container and image
- `./deploy.sh logs` - Show container logs
- `./deploy.sh shell` - Open a shell in the container

## Features

- **Multi-threaded scanning** - Fast port scanning using multiple threads
- **ARM optimization** - Optimized for Raspberry Pi architecture
- **Interactive interface** - Choose between port scanning and HTTP service checking
- **Results logging** - Scan results saved to `results/scan_results.txt`
- **Device detection** - Attempts to guess device type based on open ports
- **Colored output** - Easy-to-read colored terminal output

## Network Configuration

The container uses `--network host` mode, which allows it to:
- Access the local network directly
- Perform network scanning without NAT issues
- Scan other devices on the same network as the Raspberry Pi

## Security Considerations

- The container runs as a non-root user for security
- Results are stored in a mounted volume outside the container
- No unnecessary ports are exposed

## Troubleshooting

1. **Permission denied when running deploy.sh**
   ```bash
   chmod +x deploy.sh
   ```

2. **Docker daemon not running**
   ```bash
   sudo systemctl start docker
   sudo systemctl enable docker
   ```

3. **Network scanning not working**
   - Ensure the container is running with `--network host`
   - Check that Docker has the necessary permissions
   - Verify the Raspberry Pi is connected to the network

4. **Build fails on Raspberry Pi**
   - Make sure you have enough free space (at least 1GB)
   - Check internet connectivity for downloading dependencies

## File Locations

- **Scan results**: `./results/scan_results.txt`
- **Application logs**: Use `./deploy.sh logs` to view
- **Container data**: Stored in Docker volumes

## Performance Notes

- Scanning speed depends on network latency and target responsiveness
- The default timeout is set to 0.3 seconds per port
- Raspberry Pi 4 recommended for best performance
- Consider adjusting thread count for older Raspberry Pi models

## Customization

To modify the scanner behavior:
1. Edit `Multi-Thread Port Scanner.py`
2. Rebuild the image: `./deploy.sh build`
3. Run the updated scanner: `./deploy.sh run`