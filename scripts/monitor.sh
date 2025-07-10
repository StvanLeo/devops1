#!/bin/bash

# Monitoring script for DevOps 1
echo "📊 Starting DevOps application monitoring 1..."

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Variables
APP_URL="http://localhost:4000"
CONTAINER_NAME="my-app-prod"
MONITOR_INTERVAL=5

# Function to obtain timestamp
timestamp() {
  date '+%Y-%m-%d %H:%M:%S'
}

# Function to check application health
check_health() {
  local status_code=$(curl -s -o /dev/null -w "%{http_code}" ${APP_URL}/health 2>/dev/null)
  if [ "$status_code" = "200" ]; then
    echo -e "${GREEN}✅ [$(timestamp)] Healthy application (HTTP $status_code)${NC}"
    return 0
  else
    echo -e "${RED}❌ [$(timestamp)] Application with problems (HTTP $status_code)${NC}"
    return 1
  fi
}

# Function to get metrics
get_metrics() {
  local metrics=$(curl -s ${APP_URL}/api/stats 2>/dev/null)
  if [ $? -eq 0 ]; then 
    local requests=$(echo $metrics | grep -o '"totalRequests":[0-9]*' | cut -d':' -f2) 
    local errors=$(echo $metrics | grep -o '"totalErrors":[0-9]*' | cut -d':' -f2) 
    local uptime=$(echo $metrics | grep -o '"uptime":[0-9]*' | cut -d':' -f2) 
    local uptime_seconds=$((uptime / 1000)) 

    echo -e "${BLUE}📈 [$(timestamp)] Total Requests: $requests | Errors: $errors | Uptime: ${uptime_seconds}s${NC}" 
  else 
    echo -e "${RED}📈 [$(timestamp)] Could not get metrics${NC}" 
  fi
}

# Function to get container stats
get_container_stats() { 
  if docker ps | grep -q ${CONTAINER_NAME}; then 
    local stats=$(docker stats ${CONTAINER_NAME} --no-stream --format "table {{.CPUPerc}}\t{{.MemUsage}}" | tail -n 1) 
    echo -e "${YELLOW}🐳 [$(timestamp)] Container Stats: $stats${NC}" 
  else 
    echo -e "${RED}🐳 [$(timestamp)] Container not found${NC}" 
  fi
}

# Function to check error logs
check_error_logs() { 
  if docker ps | grep -q ${CONTAINER_NAME}; then 
    local error_count=$(docker logs ${CONTAINER_NAME} --since=30s 2>/dev/null | grep -c "ERROR") 
    if [ "$error_count" -gt 0 ]; then 
      echo -e "${RED}🚨 [$(timestamp)] $error_count errors were detected in the last 30s${NC}" 
      docker logs ${CONTAINER_NAME} --since=30s 2>/dev/null | grep "ERROR" | tail -3
    fi
  fi
}

echo -e "${BLUE}🎯 Monitoring started every $MONITOR_INTERVAL seconds${NC}"
echo -e "${YELLOW}💡 Press Ctrl+C to stop${NC}"
echo "================================================"

# Main monitoring loop
while true; do 
  check_health 
  get_metrics 
  get_container_stats 
  check_error_logs 
  echo "---------------------------------------" 
  sleep $MONITOR_INTERVAL
done
