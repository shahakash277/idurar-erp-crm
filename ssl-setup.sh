#!/bin/bash

# SSL Certificate Setup Script for Idurar ERP CRM
# This script helps set up SSL certificates for HTTPS support

set -e

SSL_DIR="./ssl"
DOMAIN="${1:-localhost}"

echo "🔐 Setting up SSL certificates for domain: $DOMAIN"

# Create SSL directory if it doesn't exist
mkdir -p "$SSL_DIR"

# Function to generate self-signed certificate
generate_self_signed() {
    echo "📝 Generating self-signed certificate for development..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$SSL_DIR/key.pem" \
        -out "$SSL_DIR/cert.pem" \
        -subj "/C=US/ST=State/L=City/O=Idurar/CN=$DOMAIN"
    echo "✅ Self-signed certificate generated successfully!"
}

# Function to setup Let's Encrypt certificate
setup_lets_encrypt() {
    echo "🌐 Setting up Let's Encrypt certificate..."
    
    if ! command -v certbot &> /dev/null; then
        echo "❌ Certbot is not installed. Please install it first:"
        echo "   sudo apt-get update && sudo apt-get install certbot"
        exit 1
    fi
    
    # Stop nginx temporarily
    docker-compose stop frontend
    
    # Get certificate
    sudo certbot certonly --standalone -d "$DOMAIN" \
        --email admin@$DOMAIN \
        --agree-tos \
        --non-interactive
    
    # Copy certificates to ssl directory
    sudo cp "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" "$SSL_DIR/cert.pem"
    sudo cp "/etc/letsencrypt/live/$DOMAIN/privkey.pem" "$SSL_DIR/key.pem"
    sudo chown $USER:$USER "$SSL_DIR"/*
    
    # Restart nginx
    docker-compose up -d frontend
    
    echo "✅ Let's Encrypt certificate setup completed!"
}

# Function to setup custom certificates
setup_custom_cert() {
    echo "📁 Setting up custom SSL certificates..."
    
    if [ ! -f "$SSL_DIR/cert.pem" ] || [ ! -f "$SSL_DIR/key.pem" ]; then
        echo "❌ Custom certificates not found in $SSL_DIR/"
        echo "   Please place your cert.pem and key.pem files in the $SSL_DIR/ directory"
        exit 1
    fi
    
    echo "✅ Custom certificates found and ready to use!"
}

# Main script logic
case "${2:-self-signed}" in
    "self-signed")
        generate_self_signed
        ;;
    "lets-encrypt")
        setup_lets_encrypt
        ;;
    "custom")
        setup_custom_cert
        ;;
    *)
        echo "Usage: $0 [domain] [cert-type]"
        echo "  domain: Your domain name (default: localhost)"
        echo "  cert-type: self-signed, lets-encrypt, or custom (default: self-signed)"
        echo ""
        echo "Examples:"
        echo "  $0 localhost self-signed"
        echo "  $0 example.com lets-encrypt"
        echo "  $0 example.com custom"
        exit 1
        ;;
esac

echo ""
echo "🚀 SSL setup completed! You can now start your application with:"
echo "   docker-compose up -d"
echo ""
echo "📋 Your application will be available at:"
echo "   HTTP:  http://$DOMAIN"
echo "   HTTPS: https://$DOMAIN" 