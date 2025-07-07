#!/bin/bash

# Cleanup script for DevOps 1
echo "🧹 Starting DevOps 1 Environment Cleanup..."

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Variables
APP_NAME="my-app-devops"
CONTAINER_NAME="my-app-prod"

echo -e "${BLUE}🛑 Stopping containers...${NC}"
docker stop ${CONTAINER_NAME} 2>/dev/null || echo "No container running"
docker stop my-app 2>/dev/null || echo "No container my-app running"

echo -e "${BLUE}🗑️ Removing containers...${NC}"
docker rm ${CONTAINER_NAME} 2>/dev/null || echo "No ${CONTAINER_NAME} container to remove"
docker rm my-app 2>/dev/null || echo "No my-app container to remove"

echo -e "${BLUE}🖼️ Removing images...${NC}"
docker rmi ${APP_NAME}:v1.0 2>/dev/null || echo "No v1.0 image to remove"
docker rmi ${APP_NAME}:v2.0-buggy 2>/dev/null || echo "No v2.0-buggy image to remove"
docker rmi test-app:latest 2>/dev/null || echo "No test-app image to remove"

echo -e "${BLUE}🧽 Cleaning up orphaned images...${NC}"
docker image prune -f

echo -e "${BLUE}📁 Cleaning up temporary files...${NC}"
rm -f *.log
rm -f .env.local
rm -rf node_modules/.cache 2>/dev/null || true

echo -e "${GREEN}✅ Cleanup complete!${NC}"
echo -e "${YELLOW}💡 To reinstall dependencies: npm install${NC}"
echo -e "${YELLOW}💡 To rebuild: ./scripts/deploy.sh${NC}"
