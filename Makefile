# Makefile for RAGFlow Container

# Variables
SHELL := /bin/bash
WORKSPACE_DIR := workspace
CONFIG_DIR := $(WORKSPACE_DIR)/config
LOGS_DIR := $(WORKSPACE_DIR)/logs
NGINX_DIR := $(WORKSPACE_DIR)/nginx
BACKUP_DIR := backups
COMPOSE_FILE := docker-compose.yml
ENV_FILE := .env
ENV_EXAMPLE := .env.example

# Docker Compose command with default options
DOCKER_COMPOSE := docker compose

# Default target
.PHONY: all
all: help

# Help target
.PHONY: help
help:
	@echo "RAGFlow Container Management"
	@echo ""
	@echo "Usage:"
	@echo "  make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  init          - Initialize directory structure and configuration files"
	@echo "  setup         - Complete setup (init + start)"
	@echo "  start         - Start all services"
	@echo "  stop          - Stop all services"
	@echo "  restart       - Restart all services"
	@echo "  status        - Show status of services"
	@echo "  logs          - View logs from all services"
	@echo "  backup        - Create backup of data volumes"
	@echo "  clean         - Remove all containers and volumes"
	@echo "  update        - Pull latest images and restart services"
	@echo ""
	@echo "Service-specific logs:"
	@echo "  logs-app      - View RAGFlow application logs"
	@echo "  logs-nginx    - View Nginx logs"
	@echo "  logs-es       - View Elasticsearch logs"
	@echo "  logs-mysql    - View MySQL logs"
	@echo "  logs-minio    - View MinIO logs"

# Initialize directories and configuration files
.PHONY: init
init:
	@echo "Creating directory structure..."
	mkdir -p $(CONFIG_DIR)
	mkdir -p $(LOGS_DIR)
	mkdir -p $(NGINX_DIR)
	mkdir -p $(BACKUP_DIR)
	@if [ ! -f "$(ENV_FILE)" ] && [ -f "$(ENV_EXAMPLE)" ]; then \
		echo "Creating $(ENV_FILE) from example..."; \
		cp $(ENV_EXAMPLE) $(ENV_FILE); \
	fi
	@if [ ! -f "$(CONFIG_DIR)/infinity_conf.toml" ]; then \
		echo "Copying Infinity configuration..."; \
		cp docker/infinity_conf.toml $(CONFIG_DIR)/; \
	fi
	@if [ ! -f "$(CONFIG_DIR)/init.sql" ]; then \
		echo "Copying MySQL initialization script..."; \
		cp docker/init.sql $(CONFIG_DIR)/; \
	fi
	@if [ ! -f "$(NGINX_DIR)/nginx.conf" ]; then \
		echo "Copying Nginx configuration..."; \
		cp docker/nginx/nginx.conf $(NGINX_DIR)/; \
		cp docker/nginx/ragflow.conf $(NGINX_DIR)/; \
		cp docker/nginx/proxy.conf $(NGINX_DIR)/; \
	fi
	@echo "Initialization complete. Please edit $(ENV_FILE) with your settings."

# Setup everything
.PHONY: setup
setup: init start

# Start services
.PHONY: start
start:
	$(DOCKER_COMPOSE) up -d

# Stop services
.PHONY: stop
stop:
	$(DOCKER_COMPOSE) down

# Restart services
.PHONY: restart
restart: stop start

# Show status
.PHONY: status
status:
	$(DOCKER_COMPOSE) ps

# View all logs
.PHONY: logs
logs:
	$(DOCKER_COMPOSE) logs -f

# Service-specific logs
.PHONY: logs-app logs-nginx logs-es logs-mysql logs-minio
logs-app:
	$(DOCKER_COMPOSE) logs -f ragflow

logs-nginx:
	$(DOCKER_COMPOSE) logs -f ragflow

logs-es:
	$(DOCKER_COMPOSE) logs -f es01

logs-mysql:
	$(DOCKER_COMPOSE) logs -f mysql

logs-minio:
	$(DOCKER_COMPOSE) logs -f minio

# Backup data volumes
.PHONY: backup
backup:
	@echo "Creating backup directory..."
	@mkdir -p $(BACKUP_DIR)
	@echo "Backing up MySQL data..."
	@docker run --rm -v ragflow-container_mysql_data:/source -v $(PWD)/$(BACKUP_DIR):/backup \
		alpine tar czf /backup/mysql_data.tar.gz -C /source ./
	@echo "Backing up Elasticsearch data..."
	@docker run --rm -v ragflow-container_esdata01:/source -v $(PWD)/$(BACKUP_DIR):/backup \
		alpine tar czf /backup/esdata01.tar.gz -C /source ./
	@echo "Backing up Infinity data..."
	@docker run --rm -v ragflow-container_infinity_data:/source -v $(PWD)/$(BACKUP_DIR):/backup \
		alpine tar czf /backup/infinity_data.tar.gz -C /source ./
	@echo "Backing up MinIO data..."
	@docker run --rm -v ragflow-container_minio_data:/source -v $(PWD)/$(BACKUP_DIR):/backup \
		alpine tar czf /backup/minio_data.tar.gz -C /source ./
	@echo "Backup complete. Files are in the $(BACKUP_DIR) directory."

# Clean everything
.PHONY: clean
clean: stop
	@echo "Removing all containers and volumes..."
	$(DOCKER_COMPOSE) down -v
	@echo "Clean complete."

# Update images and restart
.PHONY: update
update:
	@echo "Pulling latest images..."
	$(DOCKER_COMPOSE) pull
	@echo "Restarting services..."
	$(MAKE) restart
