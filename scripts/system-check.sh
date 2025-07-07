#!/bin/bash

# System check script for DevOps 1
echo "🔍 Running system check..."

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}💻 SYSTEM INFORMATION${NC}"
echo "============================================="
echo "🖥️ OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "🏗️ Architecture: $(uname -m)"
echo "⚡ Kernel: $(uname -r)"
echo "📅 Date: $(date)"
echo

echo -e "${BLUE}📊 SYSTEM RESOURCES${NC}"
echo "============================================"
echo "💾 Memory:"
free -h
echo
echo "💽 Disk:"
df -h /
echo
echo "⚙️ CPU:"
nproc --all | xargs -I {} echo "Available cores: {}"
top -bn1 | grep "Cpu(s)" | cut -d',' -f1 | cut -d':' -f2 | xargs echo "CPU usage:"
echo

echo -e "${BLUE}🔧 INSTALLED TOOLS${NC}"
echo "==============================================="

# Function to check tools
check_tool() { 
  localtool=$1 
  local cmd=$2 
  if command -v $tool > /dev/null 2>&1; then 
    local version=$($cmd 2>/dev/null | head -n1) 
    echo -e "${GREEN}✅ $tool: $version${NC}" 
  else 
    echo -e "${RED}❌ $tool: Not installed${NC}" 
  fi
}

check_tool "git" "git --version"
check_tool "docker" "docker --version"
check_tool "node" "node --version"
check_tool "npm" "npm --version"
check_tool "curl" "curl --version"
check_tool "wget" "wget --version"
check_tool "python3" "python3 --version"

echo

echo -e "${BLUE}🐳 DOCKER STATUS${NC}"
echo "============================================="
if systemctl is-active --quiet docker 2>/dev/null || pgrep dockerd > /dev/null; then 
  echo -e "${GREEN}✅ Docker daemon is running${NC}" 
  echo "📦 Docker images:" 
  docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | head -10
  echo
  echo "🏃 Active containers:"
  docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
else
  echo -e "${RED}❌ Docker daemon is not running${NC}"
fi

echo

echo -e "${BLUE}🌐 NETWORK CONNECTIVITY${NC}"
echo "============================================="
echo "🔍 Testing connectivity..."

# Test local connectivity
if curl -s http://localhost:4000/health > /dev/null 2>&1; then
  echo -e "${GREEN}✅ Local application accessible${NC}"
else
  echo -e "${YELLOW}⚠️ Local application not responding${NC}"
fi

# Test external connectivity
if ping -c 1 google.com > /dev/null 2>&1; then
  echo -e "${GREEN}✅ External connectivity OK${NC}"
else
  echo -e "${RED}❌ No external connectivity${NC}"
fi

echo

echo -e "${BLUE}📁 PROJECT STRUCTURE${NC}"
echo "============================================="
if command -v tree > /dev/null 2>&1; then
  tree -L 2 -a
else
  find . -maxdepth 2 -type f | sort
fi

echo
echo -e "${GREEN}🎉 System check complete${NC}"
