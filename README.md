# RAGFlow Container

Docker container setup for RAGFlow, a powerful Retrieval-Augmented Generation (RAG) framework.

## Overview

This repository contains a production-ready Docker Compose configuration for running RAGFlow in a containerized environment. RAGFlow is a comprehensive framework for building RAG applications that combines vector databases, language models, and document processing capabilities.

## Features

- Production-ready Docker Compose setup
- Secure configuration with environment variables
- Elasticsearch for vector storage and search
- Redis for caching and session management
- Nginx reverse proxy
- Health checks for all services
- Automatic container restart
- Volume management for data persistence
- Network isolation
- Makefile for easy management

## Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- GNU Make
- 8GB RAM minimum (16GB recommended)
- 20GB disk space minimum

## Directory Structure

```
.
├── .env                    # Environment variables configuration
├── docker-compose.yml      # Main Docker compose configuration
├── docker-compose-base.yml # Base Docker compose configuration
├── docker/                 # Original configuration templates
│   ├── infinity_conf.toml  # Infinity configuration template
│   ├── init.sql           # MySQL initialization script template
│   └── nginx/             # Nginx configuration templates
├── Makefile               # Make commands for easy management
├── workspace/             # Workspace directory (configurable via WORKSPACE_DIR)
│   ├── config/           # Configuration files
│   │   ├── infinity_conf.toml  # Infinity configuration
│   │   └── init.sql           # MySQL initialization script
│   ├── logs/             # Application logs
│   └── nginx/            # Nginx configurations
└── README.md             # This documentation
```

## Quick Start

1. Initialize the workspace and configuration:
   ```bash
   make init
   ```
   This will:
   - Create necessary directories
   - Copy configuration files to workspace
   - Create .env file from template if it doesn't exist

2. Edit configuration files as needed:
   - `.env`: Environment variables
   - `workspace/config/infinity_conf.toml`: Infinity configuration
   - `workspace/config/init.sql`: MySQL initialization
   - `workspace/nginx/*.conf`: Nginx configurations

3. Start the services:
   ```bash
   make start
   ```

## Data Storage

The application uses Docker named volumes for persistent data storage:
- `esdata01`: Elasticsearch data
- `infinity_data`: Infinity database data
- `mysql_data`: MySQL database data
- `minio_data`: MinIO object storage data

These volumes are managed by Docker and persist data across container restarts. You can use the following make commands to manage data:

```bash
# Backup all data volumes
make backup

# Clean all data (warning: this will delete all data!)
make clean
```

## Environment Variables

### Workspace Configuration
- `WORKSPACE_DIR`: Base workspace directory (default: ./workspace)
- `LOGS_DIR`: Logs directory (default: ${WORKSPACE_DIR}/logs)
- `NGINX_DIR`: Nginx configuration directory (default: ${WORKSPACE_DIR}/nginx)

### Port Configuration
- `SVR_HTTP_PORT`: Server HTTP port (default: 9380)
- `SVR_HTTP_PORT_80`: Server HTTP alternate port (default: 80)
- `SVR_HTTPS_PORT`: Server HTTPS port (default: 443)
- `ES_PORT`: Elasticsearch port
- `MYSQL_PORT`: MySQL port
- `MINIO_PORT`: MinIO API port
- `MINIO_CONSOLE_PORT`: MinIO Console port (default: 9001)

## Available Make Commands

- `make init`: Initialize workspace and copy configuration files
- `make start`: Start all services
- `make stop`: Stop all services
- `make restart`: Restart all services
- `make status`: Show status of all services
- `make logs`: View logs from all services
- `make logs-app`: View RAGFlow application logs
- `make logs-nginx`: View Nginx logs
- `make logs-es`: View Elasticsearch logs
- `make logs-mysql`: View MySQL logs
- `make logs-minio`: View MinIO logs
- `make backup`: Create backup of all data volumes
- `make clean`: Remove all containers and volumes
- `make update`: Pull latest images and restart services

## Security Configuration

Before deploying to production, make sure to:

1. Change all default passwords in `.env`:
   - `RAGFLOW_PASSWORD`
   - `ELASTICSEARCH_PASSWORD`
   - `REDIS_PASSWORD`
   - `RAGFLOW_SECRET_KEY`

2. Enable SSL:
   - Place SSL certificates in `workspace/deploy/nginx/certs/`
   - Uncomment SSL configuration in `docker-compose.yaml`
   - Update `RAGFLOW_PROTOCOL` to `https` in `.env`

## Maintenance

### Backup

Use the make command to create backups:
```bash
make backup
```

This will:
1. Create a database dump
2. Create a tar archive of the data directory
3. Store backups in the `backups` directory

### Logs

View logs using make commands:
```bash
make logs          # All services
make logs-app      # RAGFlow logs
make logs-nginx    # Nginx logs
make logs-es       # Elasticsearch logs
make logs-mysql    # MySQL logs
make logs-minio    # MinIO logs
```

## Troubleshooting

1. If services fail to start:
   ```bash
   make logs
   ```

2. If database connection fails:
   - Verify Elasticsearch credentials in `.env`
   - Check if Elasticsearch container is healthy:
     ```bash
     make status
     ```

3. For permission issues:
   ```bash
   make fix-permissions
   ```

## License

This project is licensed under the MIT License. RAGFlow itself is licensed under the Apache License 2.0.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.