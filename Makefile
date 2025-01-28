# Makefile for RAGFlow Container

# Variables
SHELL := /bin/bash
WORKSPACE_DIR := workspace
CONFIG_DIR := $(WORKSPACE_DIR)/config
DATA_DIR := $(WORKSPACE_DIR)/data
LOGS_DIR := $(WORKSPACE_DIR)/logs
DEPLOY_DIR := $(WORKSPACE_DIR)/deploy
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
	@echo "  init          - Initialize directory structure and environment file"
	@echo "  setup         - Complete setup (init + start)"
	@echo "  start         - Start all services"
	@echo "  stop          - Stop all services"
	@echo "  restart       - Restart all services"
	@echo "  status        - Show status of services"
	@echo "  logs          - View logs from all services"
	@echo "  backup        - Create backup of Elasticsearch and volumes"
	@echo "  clean         - Remove all containers and volumes"
	@echo "  update        - Pull latest images and restart services"
	@echo ""
	@echo "Service-specific logs:"
	@echo "  logs-app      - View RAGFlow application logs"
	@echo "  logs-nginx    - View Nginx logs"
	@echo "  logs-es       - View Elasticsearch logs"
	@echo "  logs-redis    - View Redis logs"

# Initialize directories and environment file
.PHONY: init
init:
	@echo "Creating directory structure..."
	mkdir -p $(CONFIG_DIR)
	mkdir -p $(DATA_DIR)
	mkdir -p $(LOGS_DIR)
	mkdir -p $(DEPLOY_DIR)/nginx/{conf.d,certs}
	mkdir -p $(BACKUP_DIR)
	@if [ ! -f "$(ENV_FILE)" ] && [ -f "$(ENV_EXAMPLE)" ]; then \
		echo "Creating $(ENV_FILE) from example..."; \
		cp $(ENV_EXAMPLE) $(ENV_FILE); \
	fi
	@if [ ! -f "$(DEPLOY_DIR)/nginx/nginx.conf" ]; then \
		echo "Copying Nginx configuration..."; \
		cp examples/nginx/nginx.conf $(DEPLOY_DIR)/nginx/; \
		cp examples/nginx/conf.d/ragflow.conf $(DEPLOY_DIR)/nginx/conf.d/; \
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
.PHONY: logs-app logs-nginx logs-es logs-redis
logs-app:
	$(DOCKER_COMPOSE) logs -f ragflow

logs-nginx:
	$(DOCKER_COMPOSE) logs -f nginx

logs-es:
	$(DOCKER_COMPOSE) logs -f es01

logs-redis:
	$(DOCKER_COMPOSE) logs -f redis

# Backup data
.PHONY: backup
backup:
	@echo "Creating backup directory..."
	mkdir -p $(BACKUP_DIR)
	@echo "Creating Elasticsearch snapshot..."
	curl -X PUT "localhost:9200/_snapshot/my_backup/snapshot_$(shell date +%Y%m%d_%H%M%S)?wait_for_completion=true"
	@echo "Backing up workspace..."
	tar -czf $(BACKUP_DIR)/ragflow-backup-$(shell date +%Y%m%d_%H%M%S).tar.gz $(WORKSPACE_DIR)/

# Clean everything
.PHONY: clean
clean: stop
	@echo "Removing containers and volumes..."
	$(DOCKER_COMPOSE) down -v
	@echo "Cleaning workspace..."
	rm -rf $(WORKSPACE_DIR)/*
	@echo "Clean complete. Run 'make init' to reinitialize."

# Update services
.PHONY: update
update:
	@echo "Pulling latest images..."
	$(DOCKER_COMPOSE) pull
	@echo "Restarting services..."
	$(DOCKER_COMPOSE) up -d

# Health check
.PHONY: health
health:
	@echo "Checking service health..."
	@curl -s http://localhost:8080/health || echo "RAGFlow is not responding"
	@echo "Checking Elasticsearch..."
	@curl -s http://localhost:9200/_cluster/health || echo "Elasticsearch is not responding"
	@echo "Checking Redis..."
	@docker compose exec redis redis-cli ping || echo "Redis is not responding"

# Show environment info
.PHONY: info
info:
	@echo "RAGFlow Container Environment Information"
	@echo "----------------------------------------"
	@echo "Docker version:"
	@docker --version
	@echo "\nDocker Compose version:"
	@docker compose version
	@echo "\nContainer status:"
	@$(DOCKER_COMPOSE) ps
	@echo "\nVolumes:"
	@docker volume ls | grep ragflow
