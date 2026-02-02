#!/bin/bash
# Map Tile Server SSL & Nginx Configuration Fix
# Run this on the server: maps.osm.n5n.live

echo "=== Step 1: Check nginx installation ==="
sudo nginx -v

echo -e "\n=== Step 2: Check current nginx config ==="
sudo nginx -t

echo -e "\n=== Step 3: Create nginx config for map tiles ==="
sudo tee /etc/nginx/sites-available/maps.osm.n5n.live << 'EOF'
server {
    listen 80;
    server_name maps.osm.n5n.live;

    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name maps.osm.n5n.live;

    # SSL certificates (will be added by certbot)
    ssl_certificate /etc/letsencrypt/live/maps.osm.n5n.live/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/maps.osm.n5n.live/privkey.pem;
    
    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Map tiles location
    location /planettiles/ {
        alias /path/to/your/tiles/;  # UPDATE THIS PATH
        
        # CORS headers for map access
        add_header Access-Control-Allow-Origin *;
        add_header Access-Control-Allow-Methods 'GET, OPTIONS';
        add_header Access-Control-Allow-Headers 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
        
        # Cache headers
        add_header Cache-Control "public, max-age=31536000";
        
        # Handle OPTIONS for CORS
        if ($request_method = 'OPTIONS') {
            add_header Access-Control-Allow-Origin *;
            add_header Access-Control-Allow-Methods 'GET, OPTIONS';
            add_header Access-Control-Max-Age 1728000;
            add_header Content-Type 'text/plain; charset=utf-8';
            add_header Content-Length 0;
            return 204;
        }
        
        # Try .pbf extension if not specified
        try_files $uri $uri.pbf =404;
    }

    # Gzip compression for tiles
    gzip on;
    gzip_types application/x-protobuf application/octet-stream;
    gzip_vary on;
}
EOF

echo -e "\n=== Step 4: Find your tiles directory ==="
echo "Looking for tile files..."
sudo find / -name "*.mvt" -o -name "*.pbf" 2>/dev/null | head -10

echo -e "\n=== Step 5: Install certbot if not installed ==="
sudo apt update
sudo apt install -y certbot python3-certbot-nginx

echo -e "\n=== Step 6: Get SSL certificate ==="
echo "IMPORTANT: Make sure DNS is pointing to this server first!"
echo "Run this command manually after DNS is confirmed:"
echo "sudo certbot --nginx -d maps.osm.n5n.live --non-interactive --agree-tos --email your@email.com"

echo -e "\n=== Step 7: Enable the site ==="
sudo ln -sf /etc/nginx/sites-available/maps.osm.n5n.live /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

echo -e "\n=== Step 8: Test nginx config ==="
sudo nginx -t

echo -e "\n=== Step 9: Reload nginx ==="
sudo systemctl reload nginx

echo -e "\n=== Step 10: Check nginx status ==="
sudo systemctl status nginx --no-pager

echo -e "\n=== Done! ==="
echo "Next steps:"
echo "1. Find your tiles directory and update the nginx config"
echo "2. Make sure DNS A record for maps.osm.n5n.live points to this server IP"
echo "3. Run: sudo certbot --nginx -d maps.osm.n5n.live"
echo "4. Test: curl -I https://maps.osm.n5n.live/planettiles/0/0/0.pbf"
