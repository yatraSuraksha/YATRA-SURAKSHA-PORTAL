#!/bin/bash
# PMTiles SSL Setup Script for maps.osm.n5n.live

echo "=== Setting up PMTiles with SSL and systemd ==="

# 1. Install nginx and certbot
echo "Installing nginx and certbot..."
sudo apt update
sudo apt install -y nginx certbot python3-certbot-nginx

# 2. Create systemd service for pmtiles
echo "Creating systemd service for pmtiles..."
sudo tee /etc/systemd/system/pmtiles.service << 'EOF'
[Unit]
Description=PMTiles Server
After=network.target

[Service]
Type=simple
User=khv
WorkingDirectory=/home/khv
ExecStart=/usr/local/bin/pmtiles serve --cors="*" --port="8080" .
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# 3. Create nginx config for reverse proxy
echo "Creating nginx configuration..."
sudo tee /etc/nginx/sites-available/maps.osm.n5n.live << 'EOF'
server {
    listen 80;
    server_name maps.osm.n5n.live;
    
    # Allow certbot to work
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
    
    # Redirect to HTTPS (will be uncommented after SSL is obtained)
    # return 301 https://$server_name$request_uri;
    
    # Proxy to pmtiles (temporary for testing)
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # CORS headers
        add_header Access-Control-Allow-Origin *;
        add_header Access-Control-Allow-Methods 'GET, OPTIONS';
        add_header Access-Control-Allow-Headers 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
        
        if ($request_method = 'OPTIONS') {
            add_header Access-Control-Allow-Origin *;
            add_header Access-Control-Allow-Methods 'GET, OPTIONS';
            add_header Access-Control-Max-Age 1728000;
            add_header Content-Type 'text/plain; charset=utf-8';
            add_header Content-Length 0;
            return 204;
        }
    }
}

server {
    listen 443 ssl http2;
    server_name maps.osm.n5n.live;
    
    # SSL certificates (will be configured by certbot)
    ssl_certificate /etc/letsencrypt/live/maps.osm.n5n.live/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/maps.osm.n5n.live/privkey.pem;
    
    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    
    # Proxy to pmtiles
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # CORS headers
        add_header Access-Control-Allow-Origin *;
        add_header Access-Control-Allow-Methods 'GET, OPTIONS';
        add_header Access-Control-Allow-Headers 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
        
        if ($request_method = 'OPTIONS') {
            add_header Access-Control-Allow-Origin *;
            add_header Access-Control-Allow-Methods 'GET, OPTIONS';
            add_header Access-Control-Max-Age 1728000;
            add_header Content-Type 'text/plain; charset=utf-8';
            add_header Content-Length 0;
            return 204;
        }
    }
}
EOF

# 4. Enable the site
echo "Enabling site..."
sudo ln -sf /etc/nginx/sites-available/maps.osm.n5n.live /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# 5. Test nginx config
echo "Testing nginx configuration..."
sudo nginx -t

# 6. Restart nginx
echo "Starting nginx..."
sudo systemctl restart nginx

# 7. Enable and start pmtiles service
echo "Starting pmtiles service..."
sudo systemctl daemon-reload
sudo systemctl enable pmtiles
sudo systemctl start pmtiles
sudo systemctl status pmtiles --no-pager

# 8. Get SSL certificate
echo ""
echo "=== Getting SSL certificate ==="
echo "Running certbot..."
sudo certbot --nginx -d maps.osm.n5n.live --non-interactive --agree-tos --email admin@yatra-suraksha.n5n.live --redirect

# 9. Test HTTPS
echo ""
echo "=== Testing HTTPS ==="
sleep 2
curl -I https://maps.osm.n5n.live/ || echo "HTTPS test failed - may need DNS propagation time"

echo ""
echo "=== Setup Complete! ==="
echo "PMTiles is now running as a service"
echo "Check status: sudo systemctl status pmtiles"
echo "View logs: sudo journalctl -u pmtiles -f"
echo "Nginx status: sudo systemctl status nginx"
echo ""
echo "Your tiles should be available at: https://maps.osm.n5n.live/"
