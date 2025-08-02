#!/bin/bash

# Test Deployment Script for Idurar ERP CRM
# Run this after deployment to verify everything is working

echo "🧪 Testing Deployment and HTTPS Setup"
echo "====================================="

# Navigate to project directory
cd ~/idurar-erp-crm

echo ""
echo "1. Checking container status:"
docker-compose ps

echo ""
echo "2. Checking SSL certificates:"
if [ -f "./ssl/cert.pem" ] && [ -f "./ssl/key.pem" ]; then
    echo "✅ SSL certificates found"
    ls -la ./ssl/
else
    echo "❌ SSL certificates missing"
fi

echo ""
echo "3. Checking nginx logs:"
docker logs frontend --tail 10

echo ""
echo "4. Testing HTTP connection (should redirect to HTTPS):"
curl -I http://localhost 2>/dev/null | head -3 || echo "HTTP test failed"

echo ""
echo "5. Testing HTTPS connection:"
curl -I https://localhost -k 2>/dev/null | head -3 || echo "HTTPS test failed"

echo ""
echo "6. Testing from external IP:"
echo "HTTP:"
curl -I http://104.154.114.203 2>/dev/null | head -3 || echo "External HTTP test failed"
echo ""
echo "HTTPS:"
curl -I https://104.154.114.203 -k 2>/dev/null | head -3 || echo "External HTTPS test failed"

echo ""
echo "7. Checking port status:"
netstat -tlnp | grep -E "(80|443)" || echo "No ports listening"

echo ""
echo "✅ Testing complete!"
echo ""
echo "If all tests pass, your deployment is working correctly!"
echo "Access your application at:"
echo "  HTTP:  http://104.154.114.203"
echo "  HTTPS: https://104.154.114.203" 