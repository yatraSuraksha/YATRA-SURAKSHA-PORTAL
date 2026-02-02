# PMTiles HTTPS Setup Instructions

## Run these commands on your server (maps.osm.n5n.live):

### 1. SSH into your server:
```bash
ssh khv@maps.osm.n5n.live
# Password: H@rs@-/5931
```

### 2. Stop the current pmtiles process:
```bash
# Find and kill the current process
sudo pkill pmtiles
# OR if running in a terminal, press Ctrl+C
```

### 3. Find where pmtiles binary is located:
```bash
which pmtiles
# If not found, locate it:
find ~ -name pmtiles -type f 2>/dev/null
```

### 4. Install nginx and certbot:
```bash
sudo apt update
sudo apt install -y nginx certbot python3-certbot-nginx
```

### 5. Create systemd service (replace /path/to/pmtiles if needed):
```bash
sudo nano /etc/systemd/system/pmtiles.service
```

Paste this:
```ini
[Unit]
Description=PMTiles Server
After=network.target

[Service]
Type=simple
User=khv
WorkingDirectory=/home/khv
ExecStart=/home/khv/pmtiles serve --cors="*" --port="8080" .
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### 6. Create nginx config:
```bash
sudo nano /etc/nginx/sites-available/maps.osm.n5n.live
```

Paste this:
```nginx
server {
    listen 80;
    server_name maps.osm.n5n.live;
    
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        
        add_header Access-Control-Allow-Origin *;
        add_header Access-Control-Allow-Methods 'GET, OPTIONS';
    }
}
```

### 7. Enable the site:
```bash
sudo ln -sf /etc/nginx/sites-available/maps.osm.n5n.live /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
```

### 8. Start pmtiles service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable pmtiles
sudo systemctl start pmtiles
sudo systemctl status pmtiles
```

### 9. Get SSL certificate:
```bash
sudo certbot --nginx -d maps.osm.n5n.live
```

When prompted:
- Enter email: your@email.com
- Agree to terms: Y
- Redirect HTTP to HTTPS: Y (option 2)

### 10. Verify it's working:
```bash
curl -I https://maps.osm.n5n.live/
systemctl status pmtiles
sudo journalctl -u pmtiles -f
```

## Done! Your tiles are now at:
`https://maps.osm.n5n.live/`

## Useful commands:
- Check pmtiles status: `sudo systemctl status pmtiles`
- View logs: `sudo journalctl -u pmtiles -f`
- Restart: `sudo systemctl restart pmtiles`
- Stop: `sudo systemctl stop pmtiles`
