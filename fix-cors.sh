#!/bin/bash

# Fix duplicate CORS headers by removing them from nginx
# PMTiles is already handling CORS with --cors="*"

echo "=== Fixing Duplicate CORS Headers ==="
echo ""

echo "1. Backup current nginx config:"
sudo cp /etc/nginx/sites-available/maps.osm.n5n.live /etc/nginx/sites-available/maps.osm.n5n.live.backup

echo "2. Remove CORS headers from nginx config:"
sudo sed -i '/add_header Access-Control-Allow-/d' /etc/nginx/sites-available/maps.osm.n5n.live

echo "3. Show updated config:"
sudo cat /etc/nginx/sites-available/maps.osm.n5n.live

echo ""
echo "4. Test nginx configuration:"
sudo nginx -t

echo ""
echo "5. Reload nginx:"
sudo systemctl reload nginx

echo ""
echo "6. Test CORS header (should show only one Access-Control-Allow-Origin):"
curl -I "https://maps.osm.n5n.live/planettiles/0/0/0.mvt" 2>&1 | grep -i "access-control"

echo ""
echo "=== Fix Complete ==="
