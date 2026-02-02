# Quick PMTiles Server Debug Commands

Connect to server:
```bash
ssh khv@maps.osm.n5n.live
```

## Run these commands to diagnose:

### 1. Check if pmtiles service is running:
```bash
sudo systemctl status pmtiles
```

### 2. Check logs for errors:
```bash
sudo journalctl -u pmtiles -n 50
```

### 3. Test pmtiles directly:
```bash
curl -I http://localhost:8080/
```

### 4. Find .pmtiles files:
```bash
find ~ -name "*.pmtiles"
```

### 5. Check nginx config:
```bash
sudo nginx -t
sudo tail -20 /var/log/nginx/error.log
```

## Common Issues & Fixes:

### Issue 1: pmtiles service not running
```bash
# Restart it
sudo systemctl restart pmtiles
sudo systemctl status pmtiles
```

### Issue 2: No .pmtiles file found
```bash
# You need a .pmtiles file in the working directory
# Download or copy your .pmtiles file, then restart
sudo systemctl restart pmtiles
```

### Issue 3: Wrong working directory in service
```bash
# Edit service to set correct WorkingDirectory
sudo nano /etc/systemd/system/pmtiles.service
# Change WorkingDirectory to where your .pmtiles file is
sudo systemctl daemon-reload
sudo systemctl restart pmtiles
```

### Issue 4: pmtiles binary not found
```bash
# Find pmtiles
which pmtiles
find ~ -name pmtiles -type f

# Update ExecStart path in service
sudo nano /etc/systemd/system/pmtiles.service
sudo systemctl daemon-reload
sudo systemctl restart pmtiles
```

### Issue 5: Port 8080 already in use
```bash
# Check what's using port 8080
sudo lsof -i :8080
# Kill it or change pmtiles port in service file
```

## After fixing, test:
```bash
# Test pmtiles directly
curl http://localhost:8080/

# Test through nginx
curl https://maps.osm.n5n.live/

# Test tile request
curl -I https://maps.osm.n5n.live/planettiles/0/0/0.mvt
```
