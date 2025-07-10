#!/bin/bash

# Complete CI/CD Pipeline for DevOps 1
set -e

echo "🚀 Running full CI/CD pipeline..."

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Variables
START_TIME=$(date +%s)
PIPELINE_ID="pipeline-$(date +%Y%m%d-%H%M%S)"

echo -e "${PURPLE}===========================================${NC}"
echo -e "${PURPLE}🏭 DEVOPS 1 CI/CD PIPELINE${NC}"
echo -e "${PURPLE}Pipeline ID: $PIPELINE_ID${NC}"
echo -e "${PURPLE}===========================================${NC}"

# Stage 1: Code Quality & Testing
echo -e "${BLUE}📋 STAGE 1: CODE QUALITY & TESTING${NC}"
echo "-------------------------------------------"

echo "🧪 Running unit tests..."
if ! ./scripts/test.sh; then
    echo -e "${RED}❌ Tests failed. Pipeline aborted.${NC}"
    exit 1
fi

echo "🔍 Checking code structure..."
if [ ! -f "app.js" ] || [ ! -f "package.json" ] || [ ! -f "Dockerfile" ]; then
    echo -e "${RED}❌ Missing essential files${NC}"
    exit 1
fi

echo "✅ Checking JavaScript syntax..."
node -c app.js

echo -e "${GREEN}✅ Stage 1 completed${NC}"
echo

# Stage 2: Build & Security Scan
echo -e "${BLUE}📦 STAGE 2: BUILD & SECURITY SCAN${NC}"
echo "-------------------------------------------"

echo "🏗️  Construyendo imagen Docker..."
docker build -t my-app-devops:pipeline-${PIPELINE_ID} .

echo "🔒 Running basic security scan..."
# We simulate a basic security scan
if docker run --rm -i hadolint/hadolint < Dockerfile > /dev/null 2>&1; then 
    echo -e "${GREEN}✅ Security scan passed${NC}"
else 
    echo -e "${YELLOW}⚠️ Security scan warnings (continuing...)${NC}"
fi

echo "📊 Analyzing image size..."
IMAGE_SIZE=$(docker images my-app-devops:pipeline-${PIPELINE_ID} --format "{{.Size}}")
echo "Image size: $IMAGE_SIZE"

echo -e "${GREEN}✅ Stage 2 completed${NC}"
echo

# Stage 3: Deploy to Staging
echo -e "${BLUE}🎭 STAGE 3: DEPLOY TO STAGING${NC}"
echo "-------------------------------------------"

echo "🚀 Deploying to staging..."
docker stop my-app-staging 2>/dev/null || true
docker rm my-app-staging 2>/dev/null || true

docker run -d \
--name my-app-staging \
-p 3001:4000 \
my-app-devops:pipeline-${PIPELINE_ID}

echo "⏳ Waiting for staging to be ready..."
sleep 8

echo "🧪 Running smoke tests in staging..."
STAGING_URL="http://localhost:3001"

# Smoke tests
for endpoint in "/" "/health" "/api/stats"; do 
    echo "Testing $endpoint..." 
    if curl -f -s ${STAGING_URL}${endpoint} > /dev/null; then 
        echo -e "${GREEN}✅ $endpoint OK${NC}" 
    else 
        echo -e "${RED}❌ $endpoint FAILED${NC}" 
        echo "Pipeline aborted - Staging tests failed" 
        exit 1 
    fi
done

echo -e "${GREEN}✅ Stage 3 completed${NC}"
echo

# Stage 4: Production Deployment
echo -e "${BLUE}🏭 STAGE 4: PRODUCTION DEPLOYMENT${NC}"
echo "-------------------------------------------"

echo "🎯 Deploying to production..."

# Blue-Green deployment simulation
echo "🔄 Implementing Blue-Green deployment..."

# Green (new version)
docker stop my-app-prod 2>/dev/null || true
docker rm my-app-prod 2>/dev/null || true

docker run -d \
--name my-app-prod \
--restart unless-stopped \
-p 4000:4000 \
my-app-devops:pipeline-${PIPELINE_ID}

echo "⏳ Verifying deployment in production..."
sleep 5

# Health checks in production
PROD_URL="http://localhost:4000"
for i in {1..5}; do 
    if curl -f -s ${PROD_URL}/health > /dev/null; then
        echo -e "${GREEN}✅ Production healthy${NC}"
        break
    fi
    if [ $i -eq 5 ]; then
        echo -e "${RED}❌ Health check failed in production${NC}"
        exit 1
    fi
    echo "Attempt $i/5..."
    sleep 2
done

echo -e "${GREEN}✅ Stage 4 completed${NC}"
echo

# Stage 5: Post-Deployment
echo -e "${BLUE}🔍 STAGE 5: POST-DEPLOYMENT MONITORING${NC}"
echo "-------------------------------------------"

echo "📊 Checking post-deployment metrics..."

# Generate some traffic for metrics
echo "🚦 Generating test traffic..."
for i in {1..10}; do 
    curl -s ${PROD_URL} > /dev/null & 
    curl -s ${PROD_URL}/health > /dev/null & 
    curl -s ${PROD_URL}/api/stats > /dev/null &
done
wait

sleep 3

# Check metrics
METRICS=$(curl -s ${PROD_URL}/api/stats)
REQUESTS=$(echo $METRICS | grep -o '"totalRequests":[0-9]*' | cut -d':' -f2)
ERRORS=$(echo $METRICS | grep -o '"totalErrors":[0-9]*' | cut -d':' -f2)

echo "📈 Total requests: $REQUESTS"
echo "❌ Total errors: $ERRORS"

if [ "$ERRORS" -gt 5 ]; then 
    echo -e "${RED}❌ Too many errors detected${NC}" 
    exit 1
fi

echo "🧹 Cleaning up temporary resources..."
docker stop my-app-staging 2>/dev/null || true
docker rm my-app-staging 2>/dev/null || true
docker rmi my-app-devops:pipeline-${PIPELINE_ID} 2>/dev/null || true

echo -e "${GREEN}✅ Stage 5 completed${NC}"

# Pipeline Summary
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo
echo -e "${PURPLE}==============================================${NC}"
echo -e "${PURPLE}🎉 PIPELINE COMPLETED SUCCESSFULLY${NC}"
echo -e "${PURPLE}=============================================${NC}"
echo -e "${GREEN}Pipeline ID: $PIPELINE_ID${NC}"
echo -e "${GREEN}Total duration: ${DURATION}s${NC}"
echo -e "${GREEN}Application deployed to: ${PROD_URL}${NC}"
echo -e "${GREEN}Health check: ${PROD_URL}/health${NC}"
echo -e "${GREEN}Metrics: ${PROD_URL}/api/stats${NC}"
echo

echo -e "${BLUE}📋 STAGE SUMMARY:${NC}"
echo "✅ Code Quality & Testing"
echo "✅ Build & Security Scan"
echo "✅ Deploy to Staging"
echo "✅ Production Deployment"
echo "✅ Post-Deployment Monitoring"

echo
echo -e "${YELLOW}🎯 Congratulations! You have completed your first CI/CD pipeline${NC}"