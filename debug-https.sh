#!/bin/bash

# HTTPS Debug Script for Idurar ERP CRM
# Run this on your VM to troubleshoot HTTPS issues

echo "🔍 HTTPS Debug Script for Idurar ERP CRM"
echo "========================================"

# Navigate to the correct directory
echo "📁 Navigating to project directory..."
cd ~/idurar-erp-crm

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ docker-compose.yml not found in current directory!"
    echo "Current directory: $(pwd)"
    echo "Available files:"
    ls -la
    exit 1
fi

echo "✅ Found docker-compose.yml in $(pwd)"

# Check if docker-compose is running
echo ""
echo "1. Checking Docker containers status:"
docker-compose ps

# Check if SSL certificates exist
echo ""
echo "2. Checking SSL certificates:"
if [ -f "./ssl/cert.pem" ] && [ -f "./ssl/key.pem" ]; then
    echo "✅ SSL certificates found:"
    ls -la ./ssl/
    echo ""
    echo "Certificate details:"
    openssl x509 -in ./ssl/cert.pem -text -noout | grep -E "(Subject:|Issuer:|Not After)"
else
    echo "❌ SSL certificates missing!"
    echo "Creating SSL directory and certificates..."
    mkdir -p ./ssl
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout ./ssl/key.pem \
        -out ./ssl/cert.pem \
        -subj "/C=US/ST=State/L=City/O=Idurar/CN=104.154.114.203"
    chmod 600 ./ssl/key.pem
    chmod 644 ./ssl/cert.pem
    echo "✅ SSL certificates created!"
fi

# Stop containers first
echo ""
echo "3. Stopping containers to fix SSL mounting..."
docker-compose down

# Check nginx configuration
echo ""
echo "4. Checking nginx configuration:"
if docker ps -a | grep -q frontend; then
    docker exec frontend nginx -t 2>/dev/null || echo "Container not running, will check after restart"
else
    echo "Frontend container not found"
fi

# Check nginx logs
echo ""
echo "5. Checking nginx logs:"
if docker ps -a | grep -q frontend; then
    docker logs frontend --tail 20
else
    echo "Frontend container not found"
fi

# Check if ports are listening
echo ""
echo "6. Checking port status:"
netstat -tlnp | grep -E "(80|443)" || echo "No ports listening (containers stopped)"

# Check docker container logs
echo ""
echo "7. Checking all container logs:"
if docker ps -a | grep -q frontend; then
    echo "Frontend logs:"
    docker logs frontend --tail 10
else
    echo "Frontend container not found"
fi

if docker ps -a | grep -q backend; then
    echo ""
    echo "Backend logs:"
    docker logs backend --tail 10
else
    echo "Backend container not found"
fi

# Fix SSL certificate mounting issue
echo ""
echo "8. Fixing SSL certificate mounting..."
echo "Current SSL directory contents:"
ls -la ./ssl/

# Ensure proper permissions
chmod 600 ./ssl/key.pem
chmod 644 ./ssl/cert.pem

# Copy certificates to container if it exists
if docker ps -a | grep -q frontend; then
    echo "Copying certificates to container..."
    docker cp ./ssl/cert.pem frontend:/etc/nginx/ssl/cert.pem
    docker cp ./ssl/key.pem frontend:/etc/nginx/ssl/key.pem
    docker exec frontend chmod 600 /etc/nginx/ssl/key.pem
    docker exec frontend chmod 644 /etc/nginx/ssl/cert.pem
fi

# Start containers
echo ""
echo "9. Starting containers with proper SSL mounting..."
docker-compose up -d

# Wait for containers to start
echo "Waiting for containers to start..."
sleep 10

# Check if containers are running
echo ""
echo "10. Checking container status after restart:"
docker-compose ps

# Test HTTP and HTTPS connectivity
echo ""
echo "11. Testing connectivity:"
echo "Testing HTTP (should redirect to HTTPS):"
curl -I http://localhost 2>/dev/null | head -5 || echo "HTTP test failed"
echo ""
echo "Testing HTTPS:"
curl -I https://localhost -k 2>/dev/null | head -5 || echo "HTTPS test failed"

# Check SSL certificate in container
echo ""
echo "12. Checking SSL certificate in container:"
if docker ps | grep -q frontend; then
    docker exec frontend ls -la /etc/nginx/ssl/
else
    echo "Frontend container not running"
fi

# Check nginx configuration in container
echo ""
echo "13. Checking nginx configuration in container:"
if docker ps | grep -q frontend; then
    docker exec frontend nginx -t
    echo ""
    echo "Nginx configuration:"
    docker exec frontend cat /etc/nginx/conf.d/default.conf | head -20
else
    echo "Frontend container not running"
fi

echo ""
echo "🔧 Troubleshooting complete!"
echo ""
echo "If HTTPS is still not working, try these manual steps:"
echo "1. Check if containers are running: docker-compose ps"
echo "2. Check nginx logs: docker logs frontend"
echo "3. Check firewall: sudo ufw status"
echo "4. Check if port 443 is open: sudo netstat -tlnp | grep 443"
echo "5. Test from outside: curl -I https://104.154.114.203 -k" 