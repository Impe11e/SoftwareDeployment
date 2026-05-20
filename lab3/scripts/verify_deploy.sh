#!/bin/bash
set -e

TARGET_IP="${TARGET_NODE_IP:-192.168.122.156}"

echo "=== LAUNCH OF VERIFICATION OF DEPLOYMENT ==="

echo "1. Checking site availability through Nginx..."
STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://$TARGET_IP:8080/)

if [ "$STATUS_CODE" -eq 200 ]; then
    echo "✅ Success! Service is available, response status: 200 OK"
else
    echo "❌ Error! Service return status: $STATUS_CODE"
    exit 1
fi

echo "2. Inspecting Nginx headers..."
SERVER_HEADER=$(curl -sI http://$TARGET_IP:8080/ | grep -i "Server:" | awk '{print $2}' | tr -d '\r')

if [[ "$SERVER_HEADER" == *"nginx"* ]]; then
    echo "✅ Success! Requests are being handled by the Nginx server ($SERVER_HEADER)"
else
    echo "❌ Error! Nginx header not found in cookies/response. Received: $SERVER_HEADER"
    exit 1
fi

echo "========================================="
echo "🎉 VERIFICATION SUCCESSFUL! The project is working correctly. 🎉"
echo "========================================="