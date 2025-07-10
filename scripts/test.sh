#!/bin/bash

# Testing script for DevOps 1
set -e

echo "🧪 Running tests for DevOps 1..."

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Variables
APP_URL="http://localhost:4000"
TESTS_PASSED=0
TESTS_FAILED=0

# Test function
run_test() { 
    local test_name="$1" 
    local test_command="$2" 
    local expected_status="$3" 

    echo -e "${BLUE}🔍 Testing: ${test_name}${NC}" 

    if eval "$test_command"; then 
        echo -e "${GREEN}✅ PASS: ${test_name}${NC}" 
        ((++TESTS_PASSED))
    else 
        echo -e "${RED}❌ FAIL: ${test_name}${NC}" 
        ((++TESTS_FAILED))
    fi 
    echo
}

echo -e "${YELLOW}📋 Starting test suite...${NC}"
echo

# Test 1: Verify that Node.js is installed
run_test "Node.js installed" "node --version > /dev/null 2>&1"

# Test 2: Verify that npm is installed
run_test "npm installed" "npm --version > /dev/null 2>&1"

# Test 3: Verify that Docker is installed
run_test "Docker installed" "docker --version > /dev/null 2>&1"

# Test 4: Check project dependencies
run_test "Installed dependencies" "test -d node_modules && test -f node_modules/express/package.json"

# Test 5: Verify main files
run_test "App.js file exists" "test -f app.js"
run_test "File package.json exists" "test -f package.json"
run_test "Dockerfile exists" "test -f Dockerfile"

# Test 6: JavaScript Syntax
run_test "Valid JavaScript Syntax" "node -c app.js"

# Test 7: Docker Build Test
run_test "Docker build successful" "docker build -t test-app:latest . > /dev/null 2>&1"

# If an application is running, run endpoint tests
if curl -s ${APP_URL}/health > /dev/null 2>&1; then 
    echo -e "${BLUE}🌐 Application detected running, running endpoint tests...${NC}" 

    # Main endpoint test 
    run_test "Primary endpoint responds" "curl -s ${APP_URL} | grep -q 'DevOps Bootcamp'" 

    # Health check test 
    run_test "Health check responds OK" "curl -s ${APP_URL}/health | grep -q '\"status\":\"OK\"'" 

    # Stats test 
    run_test "Stats endpoint responds" "curl -s ${APP_URL}/api/stats | grep -q 'totalRequests'" 

    # Test response code 
    run_test "Status code 200 in /" "test \$(curl -s -o /dev/null -w '%{http_code}' ${APP_URL}) -eq 200"

    # Error endpoint test
    run_test "Error endpoint response 500" "test \$(curl -s -o /dev/null -w '%{http_code}' ${APP_URL}/api/error) -eq 500"

else
    echo -e "${YELLOW}⚠️ No application detected running, skipping endpoint tests${NC}"
fi

# Test image cleanup
docker rmi test-app:latest > /dev/null 2>&1 || true

# Summary
echo "=============================================="
echo -e "${BLUE}📊 TESTS SUMMARY${NC}"
echo "=============================================="
echo -e "${GREEN}✅ Tests passed: ${TESTS_PASSED}${NC}"
echo -e "${RED}❌ Tests failed: ${TESTS_FAILED}${NC}"
echo "Total tests: $((TESTS_PASSED + TESTS_FAILED))"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed! Your application is ready.${NC}"
    exit 0
else
    echo -e "${RED}💥 Some tests failed. Check the errors above.${NC}"
    exit 1
fi
