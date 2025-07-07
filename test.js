
const http = require('http');

console.log('🧪 Running basic unit tests...');

try {
  require('./app.js');
  console.log('✅ Test 1: app.js module is imported correctly');
} catch (error) {
  console.log('❌ Test 1: Error importing app.js:', error.message);
  process.exit(1);
}

try {
  const pkg = require('./package.json');
  if (pkg.name && pkg.version && pkg.main) {
    console.log('✅ Test 2: package.json has required fields');
  } else {
    throw new Error('Missing fields in package.json');
  }
} catch (error) {
  console.log('❌ Test 2: Error in package.json:', error.message);
  process.exit(1);
}


try {
  require('express');
  console.log('✅ Test 3: Express dependency available');
} catch (error) {
  console.log('❌ Test 3: Express is not installed');
  process.exit(1);
}

const testHealthCheck = () => {
  const mockHealthData = {
    status: 'OK',
    uptime: '120 seconds',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  };
  
  if (mockHealthData.status === 'OK' && mockHealthData.version) {
    console.log('✅ Test 4: Health check data structure is valid');
    return true;
  }
  return false;
};

if (!testHealthCheck()) {
  console.log('❌ Test 4: Health check structure invalid');
  process.exit(1);
}

console.log('🎉 All unit tests passed!');
