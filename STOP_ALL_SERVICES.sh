#!/bin/bash

# SmartPOS Complete System Shutdown Script

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     SmartPOS Complete System Shutdown                   ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Stop Backend API
if [ -f /tmp/backend-api.pid ]; then
    BACKEND_PID=$(cat /tmp/backend-api.pid)
    echo -e "${YELLOW}Stopping Backend API (PID: $BACKEND_PID)...${NC}"
    kill $BACKEND_PID 2>/dev/null || true
    rm /tmp/backend-api.pid
    echo -e "${GREEN}✅ Backend API stopped${NC}"
else
    echo -e "${YELLOW}⚠️  Backend API PID file not found${NC}"
fi

# Stop Device Bridge
if [ -f /tmp/device-bridge.pid ]; then
    DEVICE_PID=$(cat /tmp/device-bridge.pid)
    echo -e "${YELLOW}Stopping Device Bridge (PID: $DEVICE_PID)...${NC}"
    kill $DEVICE_PID 2>/dev/null || true
    rm /tmp/device-bridge.pid
    echo -e "${GREEN}✅ Device Bridge stopped${NC}"
else
    echo -e "${YELLOW}⚠️  Device Bridge PID file not found${NC}"
fi

# Stop Docker containers
echo -e "${YELLOW}Stopping PostgreSQL and Redis...${NC}"
cd /home/user/Flutter-Database/backend
docker-compose down
echo -e "${GREEN}✅ PostgreSQL and Redis stopped${NC}"

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          ✅ ALL SERVICES STOPPED SUCCESSFULLY            ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
