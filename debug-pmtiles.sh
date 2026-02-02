#!/bin/bash
# Debug PMTiles Server Issues

echo "=== Checking PMTiles Service Status ==="
ssh khv@maps.osm.n5n.live << 'ENDSSH'

echo "1. Check if pmtiles service is running:"
sudo systemctl status pmtiles --no-pager

echo -e "\n2. Check pmtiles logs:"
sudo journalctl -u pmtiles -n 50 --no-pager

echo -e "\n3. Check if pmtiles is listening on port 8080:"
sudo netstat -tlnp | grep 8080 || sudo ss -tlnp | grep 8080

echo -e "\n4. Test pmtiles directly (localhost):"
curl -I http://localhost:8080/ 2>&1 | head -10

echo -e "\n5. Check nginx status:"
sudo systemctl status nginx --no-pager

echo -e "\n6. Check nginx error logs:"
sudo tail -20 /var/log/nginx/error.log

echo -e "\n7. Test nginx (localhost):"
curl -I http://localhost/ 2>&1 | head -10

echo -e "\n8. List .pmtiles files in home directory:"
find /home/khv -name "*.pmtiles" -ls

echo -e "\n9. Check current directory and pmtiles binary:"
pwd
which pmtiles
ls -la pmtiles 2>/dev/null || echo "pmtiles binary not in current directory"

echo -e "\n10. Check if pmtiles process is running:"
ps aux | grep pmtiles | grep -v grep

ENDSSH
