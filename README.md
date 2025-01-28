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
├── docker-compose.yaml     # Docker compose configuration
├── Makefile               # Make commands for easy management
├── workspace/             # Workspace directory
│   ├── deploy/            # Deployment configurations
│   │   ├── nginx/        # Nginx configurations and certificates
│   │   │   └── certs/    # SSL certificates
│   │   └── pgsql/        # PostgreSQL configurations
│   │       └── certs/    # PostgreSQL SSL certificates
│   └── mydata/           # RAGFlow data directory
│       ├── data          # Application data
│       ├── export        # Export directory
│       └── upload        # Upload directory
└── README.md             # This documentation
```

## Quick Start

1. Clone this repository:
   ```bash
   git clone https://github.com/entelecheia/ragflow-container.git
   cd ragflow-container
   ```

2. Create workspace directories:
   ```bash
   mkdir -p workspace/{config,data,logs,deploy/nginx/{conf.d,certs}}
   ```

3. Copy example configurations:
   ```bash
   cp examples/nginx/nginx.conf workspace/deploy/nginx/
   cp examples/nginx/conf.d/ragflow.conf workspace/deploy/nginx/conf.d/
   cp .env.example .env
   ```

4. Edit the `.env` file to set your desired configuration:
   - Change default passwords
   - Configure Elasticsearch settings
   - Set Redis password
   - Adjust ports if needed

5. Start the services:
   ```bash
   docker compose up -d
   ```

6. Access RAGFlow:
   - Web Interface: http://localhost:8080
   - API Documentation: http://localhost:8080/docs
   - Health Check: http://localhost:8080/health

## Using the Makefile

The project includes a Makefile for easy management of common tasks:

```bash
# Complete setup
make setup              # Initialize, build, and start services

# Service management
make start             # Start all services
make stop              # Stop all services
make restart           # Restart all services
make status            # Show service status
make update            # Update services to latest version

# Logs
make logs              # View all logs
make logs-app          # View RAGFlow logs
make logs-nginx        # View Nginx logs
make logs-db           # View Elasticsearch logs
make logs-redis        # View Redis logs

# Maintenance
make backup            # Create backup of database and volumes
make clean             # Remove all containers and volumes
make fix-permissions   # Fix data directory permissions
```

For a complete list of available commands, run:
```bash
make help
```

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

## Environment Variables

See the `.env` file for all available configuration options. Key variables include:

### Authentication Configuration
- `RAGFLOW_USERNAME`: Admin username (default: admin)
  - Used for initial admin account creation
  - Passed directly to RAGFlow on startup
- `RAGFLOW_PASSWORD`: Admin password
  - Must be changed from default in production
  - Passed directly to RAGFlow on startup
- `RAGFLOW_SECRET_KEY`: Django secret key for session security
  - Must be changed in production
  - Used for cryptographic signing
- `RAGFLOW_DISABLE_SIGNUP_WITHOUT_LINK`: Disable public signups (default: true)
  - Set to false to allow public user registration

### Port Configuration
- `NGINX_HTTP_PORT`: HTTP port for web interface (default: 8080)
- `NGINX_HTTPS_PORT`: HTTPS port for web interface (default: 8081)
- `APP_PORT`: Internal application port (default: 8000)
- `ELASTICSEARCH_PORT`: Elasticsearch port (default: 9200)
- `REDIS_PORT`: Redis port (default: 6379)

### Database Configuration
- `ELASTICSEARCH_USER`: Elasticsearch username
- `ELASTICSEARCH_PASSWORD`: Elasticsearch password
- `ELASTICSEARCH_HOST`: Elasticsearch host

### Cache Configuration
- `REDIS_HOST`: Redis host
- `REDIS_PASSWORD`: Redis password

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
make logs-db       # Elasticsearch logs
make logs-redis    # Redis logs
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