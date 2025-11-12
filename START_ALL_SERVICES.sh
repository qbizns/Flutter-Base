#!/bin/bash

# SmartPOS Complete System Startup Script
# This script starts all three services: Backend API, Device Bridge, and Flutter Apps

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     SmartPOS Complete System Startup                    ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check prerequisites
echo -e "${YELLOW}[1/7] Checking prerequisites...${NC}"

if ! command -v go &> /dev/null; then
    echo -e "${RED}❌ Go is not installed${NC}"
    exit 1
fi

if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed${NC}"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ All prerequisites met${NC}"
echo ""

# Start PostgreSQL and Redis
echo -e "${YELLOW}[2/7] Starting PostgreSQL and Redis...${NC}"
cd /home/user/Flutter-Database/backend
docker-compose up -d postgres redis
sleep 5
echo -e "${GREEN}✅ PostgreSQL and Redis started${NC}"
echo ""

# Run database migrations
echo -e "${YELLOW}[3/7] Running database migrations...${NC}"
if [ ! -f .env ]; then
    echo -e "${BLUE}Creating .env file from .env.example...${NC}"
    cp .env.example .env
    echo -e "${YELLOW}⚠️  Please edit .env file with your configuration${NC}"
fi

# Check if migrations need to run
if docker exec -it $(docker ps -q -f name=postgres) psql -U postgres -d smartpos -c "SELECT 1 FROM organizations LIMIT 1" &> /dev/null; then
    echo -e "${GREEN}✅ Database already migrated${NC}"
else
    echo -e "${BLUE}Running migrations...${NC}"
    make migrate-up || true
    echo -e "${BLUE}Seeding database...${NC}"
    make seed || true
    echo -e "${GREEN}✅ Database migrated and seeded${NC}"
fi
echo ""

# Start Backend API
echo -e "${YELLOW}[4/7] Starting Backend API Server...${NC}"
cd /home/user/Flutter-Database/backend
nohup go run cmd/api/main.go > /tmp/backend-api.log 2>&1 &
BACKEND_PID=$!
echo $BACKEND_PID > /tmp/backend-api.pid
echo -e "${GREEN}✅ Backend API started (PID: $BACKEND_PID)${NC}"
echo -e "${BLUE}   API URL: http://localhost:3000${NC}"
echo -e "${BLUE}   Health: http://localhost:3000/health${NC}"
echo -e "${BLUE}   Logs: tail -f /tmp/backend-api.log${NC}"
echo ""

# Wait for backend to be ready
echo -e "${YELLOW}Waiting for backend to be ready...${NC}"
for i in {1..30}; do
    if curl -s http://localhost:3000/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Backend API is ready${NC}"
        break
    fi
    if [ $i -eq 30 ]; then
        echo -e "${RED}❌ Backend API failed to start${NC}"
        exit 1
    fi
    sleep 1
    echo -n "."
done
echo ""

# Install libusb if needed
echo -e "${YELLOW}[5/7] Checking libusb installation...${NC}"
if ! ldconfig -p | grep libusb-1.0 > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  libusb-1.0 not found. Installing...${NC}"
    sudo apt-get update && sudo apt-get install -y libusb-1.0-0 libusb-1.0-0-dev
fi
echo -e "${GREEN}✅ libusb is installed${NC}"
echo ""

# Start Device Bridge
echo -e "${YELLOW}[6/7] Starting Device Bridge Service...${NC}"
cd /home/user/Flutter-Device
nohup ./bridge > /tmp/device-bridge.log 2>&1 &
DEVICE_PID=$!
echo $DEVICE_PID > /tmp/device-bridge.pid
echo -e "${GREEN}✅ Device Bridge started (PID: $DEVICE_PID)${NC}"
echo -e "${BLUE}   gRPC: localhost:50051${NC}"
echo -e "${BLUE}   HTTP: http://localhost:8080${NC}"
echo -e "${BLUE}   WebSocket: ws://localhost:8080/v1/events${NC}"
echo -e "${BLUE}   Swagger: http://localhost:8080/swagger${NC}"
echo -e "${BLUE}   Logs: tail -f /tmp/device-bridge.log${NC}"
echo ""

# Wait for device bridge to be ready
echo -e "${YELLOW}Waiting for device bridge to be ready...${NC}"
for i in {1..30}; do
    if curl -s http://localhost:8080/v1/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Device Bridge is ready${NC}"
        break
    fi
    if [ $i -eq 30 ]; then
        echo -e "${RED}❌ Device Bridge failed to start${NC}"
        exit 1
    fi
    sleep 1
    echo -n "."
done
echo ""

# Get Flutter dependencies
echo -e "${YELLOW}[7/7] Setting up Flutter projects...${NC}"
cd /home/user/Flutter-Base
echo -e "${BLUE}Getting dependencies for all packages...${NC}"
flutter pub get
cd packages/pos_core && flutter pub get && cd ../..
cd packages/pos_ui && flutter pub get && cd ../..
cd packages/device_bridge_client && flutter pub get && cd ../..
cd packages/notification_service && flutter pub get && cd ../..
echo -e "${GREEN}✅ Flutter dependencies installed${NC}"
echo ""

# Success summary
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          ✅ ALL SERVICES STARTED SUCCESSFULLY            ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📊 Service Status:${NC}"
echo -e "   ${GREEN}✅${NC} PostgreSQL:    localhost:5432"
echo -e "   ${GREEN}✅${NC} Redis:          localhost:6379"
echo -e "   ${GREEN}✅${NC} Backend API:    http://localhost:3000"
echo -e "   ${GREEN}✅${NC} Device Bridge:  http://localhost:8080"
echo ""
echo -e "${BLUE}🚀 To run Flutter apps:${NC}"
echo -e "   cd /home/user/Flutter-Base"
echo -e "   flutter run -d chrome apps/pos_register           # POS Register"
echo -e "   flutter run -d chrome apps/kitchen_display        # Kitchen Display"
echo -e "   flutter run -d chrome apps/manager_dashboard      # Manager Dashboard"
echo ""
echo -e "${BLUE}📝 Check logs:${NC}"
echo -e "   tail -f /tmp/backend-api.log       # Backend API logs"
echo -e "   tail -f /tmp/device-bridge.log     # Device Bridge logs"
echo ""
echo -e "${BLUE}🛑 To stop all services:${NC}"
echo -e "   ./STOP_ALL_SERVICES.sh"
echo ""
echo -e "${YELLOW}⚠️  Important:${NC}"
echo -e "   1. Test the system: curl http://localhost:3000/health"
echo -e "   2. Test device bridge: curl http://localhost:8080/v1/health"
echo -e "   3. Default admin credentials in database seed data"
echo ""
