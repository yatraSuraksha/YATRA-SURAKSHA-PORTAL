# Map Tile Server SSL Setup - Step by Step Guide

## Connect to your server:
```bash
ssh khv@maps.osm.n5n.live
# Password: H@rs@-/5931
```

## Quick Fix Commands (copy and paste these):

### 1. Find where your map tiles are stored:
```bash
find ~ -name "*.mvt" -o -name "*.pbf" 2>/dev/null | head -5
# OR
find /var -name "*.mvt" -o -name "*.pbf" 2>/dev/null | head -5
# OR
find /opt -name "*.mvt" -o -name "*.pbf" 2>/dev/null | head -5
```

### 2. Install nginx and certbot:
```bash
sudo apt update
sudo apt install -y nginx certbot python3-certbot-nginx
```

### 3. Create nginx config (UPDATE /path/to/your/tiles/ with actual path):
```bash
sudo nano /etc/nginx/sites-available/maps.osm.n5n.live
```

Paste this (replace `/path/to/your/tiles/` with your actual tiles directory):
```nginx
server {
    listen 80;
    listen 443 ssl http2;
    server_name maps.osm.n5n.live;

    # SSL will be configured by certbot
    
    location /planettiles/ {
        alias /path/to/your/tiles/;  # UPDATE THIS!
        
        add_header Access-Control-Allow-Origin *;
        add_header Access-Control-Allow-Methods 'GET, OPTIONS';
        add_header Cache-Control "public, max-age=31536000";
        
        try_files $uri $uri.pbf $uri.mvt =404;
    }
    
    gzip on;
    gzip_types application/x-protobuf application/octet-stream;
}
```

### 4. Enable the site:
```bash
sudo ln -sf /etc/nginx/sites-available/maps.osm.n5n.live /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 5. Get SSL certificate:
```bash
sudo certbot --nginx -d maps.osm.n5n.live --agree-tos --email your@email.com
```

### 6. Test:
```bash
curl -I https://maps.osm.n5n.live/planettiles/0/0/0.pbf
```

## If tiles aren't working, check:
1. Tile file permissions: `sudo chmod -R 755 /path/to/tiles/`
2. Nginx can read: `sudo -u www-data ls /path/to/tiles/`
3. Check nginx error log: `sudo tail -f /var/log/nginx/error.log`

## After it's working, update your App.jsx:
Change tile URL to: `https://maps.osm.n5n.live/planettiles/{z}/{x}/{y}.pbf`
