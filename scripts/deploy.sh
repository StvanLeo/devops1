#!/bin/bash

# Deploy script para DevOps Day 1
set -e  # Exit on error

echo "🚀 Starting deployment of DevOps application 1..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables
APP_NAME="my-app-devops"
VERSION="v1.0"
CONTAINER_NAME="my-app-prod"
PORT=4000

echo -e "${BLUE}📦 Step 1: Building Docker image...${NC}"
docker build -t ${APP_NAME}:${VERSION} .

echo -e "${BLUE}🔍 Step 2: Verifying image...${NC}"
docker images | grep ${APP_NAME}

echo -e "${BLUE}🛑 Step 3: Stopping previous container (if one exists)...${NC}"
docker stop ${CONTAINER_NAME} 2>/dev/null || echo "No previous container running"
docker rm ${CONTAINER_NAME} 2>/dev/null || echo "No previous container to remove"

echo -e "${BLUE}🚀 Step 4: Deploying new version...${NC}"
docker run -d \
  --name ${CONTAINER_NAME} \
  --restart unless-stopped \
  -p ${PORT}:${PORT} \
  ${APP_NAME}:${VERSION}

echo -e "${BLUE}⏳ Step 5: Waiting for the application to be ready...${NC}"
sleep 5

echo -e "${BLUE}🏥 Step 6: Verifying health check...${NC}"
for i in {1..10}; do
  if curl -s http://localhost:${PORT}/health > /dev/null; then
    echo -e "${GREEN}✅ Application successfully deployed!${NC}"
    echo -e "${GREEN}🌐 Access to: http://localhost:${PORT}${NC}"
    echo -e "${GREEN}🏥 Health check: http://localhost:${PORT}/health${NC}"
    echo -e "${GREEN}📊 Stats: http://localhost:${PORT}/api/stats${NC}"
    exit 0
  fi
  echo "Attempt $i/10 - Waiting..."
  sleep 2
done

echo -e "${RED}❌ Error: Application not responding after 20 seconds${NC}"
echo -e "${YELLOW}📋 Container logs:${NC}"
docker logs ${CONTAINER_NAME}
exit 1
