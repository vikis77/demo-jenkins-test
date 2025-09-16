#!/bin/bash

# SpringBoot Demo 916 Auto Deploy Script
# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

APP_NAME="springboot-demo-916"
JAR_FILE="target/${APP_NAME}.jar"
DEPLOY_DIR="/opt/apps/${APP_NAME}"
LOG_FILE="${DEPLOY_DIR}/app.log"
PID_FILE="${DEPLOY_DIR}/app.pid"

echo -e "${BLUE}"
echo "========================================"
echo "  SpringBoot Demo 916 Auto Deploy"
echo "========================================"
echo -e "${NC}"

# Check if JAR file exists
if [ ! -f "$JAR_FILE" ]; then
    echo -e "${RED}[ERROR] JAR file not found: $JAR_FILE${NC}"
    echo -e "${YELLOW}[INFO] Please run 'mvn clean package' first${NC}"
    exit 1
fi

# Function to check if application is running
check_app_running() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            return 0
        else
            rm -f "$PID_FILE"
            return 1
        fi
    else
        return 1
    fi
}

# Stop existing application
echo -e "${BLUE}[INFO] Checking for existing application...${NC}"
if check_app_running; then
    echo -e "${YELLOW}[INFO] Stopping existing application (PID: $(cat $PID_FILE))...${NC}"
    kill $(cat "$PID_FILE") 2>/dev/null || true
    sleep 3

    # Force kill if still running
    if check_app_running; then
        echo -e "${YELLOW}[WARNING] Force killing application...${NC}"
        kill -9 $(cat "$PID_FILE") 2>/dev/null || true
        rm -f "$PID_FILE"
    fi
    echo -e "${GREEN}[INFO] Application stopped${NC}"
else
    echo -e "${BLUE}[INFO] No existing application found${NC}"
fi

# Create deployment directory
echo -e "${BLUE}[INFO] Creating deployment directory...${NC}"
sudo mkdir -p "$DEPLOY_DIR"
sudo chown $(whoami):$(whoami) "$DEPLOY_DIR"

# Copy JAR file
echo -e "${BLUE}[INFO] Copying JAR file to deployment directory...${NC}"
cp "$JAR_FILE" "$DEPLOY_DIR/"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}[INFO] JAR file copied successfully${NC}"
else
    echo -e "${RED}[ERROR] Failed to copy JAR file${NC}"
    exit 1
fi

# Start application
echo -e "${BLUE}[INFO] Starting SpringBoot application...${NC}"
cd "$DEPLOY_DIR"

# Start application in background and save PID
nohup java -jar "${APP_NAME}.jar" > "$LOG_FILE" 2>&1 &
APP_PID=$!
echo $APP_PID > "$PID_FILE"

echo -e "${BLUE}[INFO] Application started with PID: $APP_PID${NC}"
echo -e "${BLUE}[INFO] Waiting for application to initialize...${NC}"

# Health check
for i in {1..30}; do
    if curl -s http://localhost:8080 > /dev/null 2>&1; then
        echo -e "${GREEN}"
        echo "========================================"
        echo "  APPLICATION STARTED SUCCESSFULLY!"
        echo "========================================"
        echo "  URL: http://localhost:8080"
        echo "  PID: $APP_PID"
        echo "  Log: $LOG_FILE"
        echo "  Deploy Dir: $DEPLOY_DIR"
        echo "========================================"
        echo -e "${NC}"

        # Show last few lines of log
        echo -e "${YELLOW}[INFO] Last 10 lines of application log:${NC}"
        tail -n 10 "$LOG_FILE"

        exit 0
    fi
    echo -e "${YELLOW}[INFO] Waiting for application to start... ($i/30)${NC}"
    sleep 2
done

echo -e "${YELLOW}[WARNING] Health check timeout, but application may still be starting...${NC}"
echo -e "${BLUE}[INFO] Check the log file: $LOG_FILE${NC}"
echo -e "${BLUE}[INFO] Application PID: $APP_PID${NC}"

# Show status commands
echo -e "${BLUE}"
echo "========================================"
echo "  USEFUL COMMANDS:"
echo "========================================"
echo "  Check status: ps -p $APP_PID"
echo "  View logs: tail -f $LOG_FILE"
echo "  Stop app: kill $APP_PID"
echo "  Check URL: curl http://localhost:8080"
echo "========================================"
echo -e "${NC}"