#!/bin/bash
#
# Raspberry Pi Port Scanner Docker Deployment Script
# Usage: ./deploy.sh [build|run|stop|clean]

set -e

IMAGE_NAME="raspberry-port-scanner"
CONTAINER_NAME="port-scanner"
RESULTS_DIR="./results"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_help() {
    echo -e "${YELLOW}Raspberry Pi Port Scanner Docker Deployment${NC}"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  build     Build the Docker image"
    echo "  run       Run the port scanner interactively"
    echo "  stop      Stop the running container"
    echo "  clean     Remove container and image"
    echo "  logs      Show container logs"
    echo "  shell     Open a shell in the container"
    echo ""
    echo "Examples:"
    echo "  $0 build     # Build the image"
    echo "  $0 run       # Run the scanner"
    echo ""
}

build_image() {
    echo -e "${YELLOW}Building Docker image for Raspberry Pi...${NC}"
    
    # Create results directory if it doesn't exist
    mkdir -p "$RESULTS_DIR"
    
    # Build the image
    docker build -t "$IMAGE_NAME" .
    
    echo -e "${GREEN}✓ Image built successfully!${NC}"
}

run_scanner() {
    echo -e "${YELLOW}Starting port scanner...${NC}"
    
    # Create results directory if it doesn't exist
    mkdir -p "$RESULTS_DIR"
    
    # Stop existing container if running
    if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
        echo -e "${YELLOW}Stopping existing container...${NC}"
        docker stop "$CONTAINER_NAME" >/dev/null 2>&1
    fi
    
    # Remove existing container if exists
    if docker ps -aq -f name="$CONTAINER_NAME" | grep -q .; then
        docker rm "$CONTAINER_NAME" >/dev/null 2>&1
    fi
    
    # Run the container
    docker run -it \
        --name "$CONTAINER_NAME" \
        --network host \
        -v "$(pwd)/$RESULTS_DIR:/app/results" \
        "$IMAGE_NAME"
}

stop_container() {
    echo -e "${YELLOW}Stopping container...${NC}"
    
    if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
        docker stop "$CONTAINER_NAME"
        echo -e "${GREEN}✓ Container stopped${NC}"
    else
        echo -e "${YELLOW}Container is not running${NC}"
    fi
}

clean_up() {
    echo -e "${YELLOW}Cleaning up Docker resources...${NC}"
    
    # Stop and remove container
    if docker ps -aq -f name="$CONTAINER_NAME" | grep -q .; then
        docker stop "$CONTAINER_NAME" >/dev/null 2>&1 || true
        docker rm "$CONTAINER_NAME" >/dev/null 2>&1
        echo -e "${GREEN}✓ Container removed${NC}"
    fi
    
    # Remove image
    if docker images -q "$IMAGE_NAME" | grep -q .; then
        docker rmi "$IMAGE_NAME" >/dev/null 2>&1
        echo -e "${GREEN}✓ Image removed${NC}"
    fi
    
    echo -e "${GREEN}✓ Cleanup completed${NC}"
}

show_logs() {
    echo -e "${YELLOW}Container logs:${NC}"
    docker logs "$CONTAINER_NAME" 2>/dev/null || echo -e "${RED}Container not found or not running${NC}"
}

open_shell() {
    echo -e "${YELLOW}Opening shell in container...${NC}"
    
    if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
        docker exec -it "$CONTAINER_NAME" /bin/bash
    else
        echo -e "${RED}Container is not running. Starting a new container with shell...${NC}"
        mkdir -p "$RESULTS_DIR"
        docker run -it --rm \
            --name "$CONTAINER_NAME-shell" \
            --network host \
            -v "$(pwd)/$RESULTS_DIR:/app/results" \
            "$IMAGE_NAME" /bin/bash
    fi
}

# Check if Docker is installed and running
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Error: Docker is not installed${NC}"
        echo "Please install Docker first: https://docs.docker.com/engine/install/"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        echo -e "${RED}Error: Docker daemon is not running${NC}"
        echo "Please start the Docker service"
        exit 1
    fi
}

# Main script logic
case "$1" in
    build)
        check_docker
        build_image
        ;;
    run)
        check_docker
        # Build if image doesn't exist
        if ! docker images -q "$IMAGE_NAME" | grep -q .; then
            echo -e "${YELLOW}Image not found. Building first...${NC}"
            build_image
        fi
        run_scanner
        ;;
    stop)
        check_docker
        stop_container
        ;;
    clean)
        check_docker
        clean_up
        ;;
    logs)
        check_docker
        show_logs
        ;;
    shell)
        check_docker
        open_shell
        ;;
    help|--help|-h)
        print_help
        ;;
    "")
        print_help
        ;;
    *)
        echo -e "${RED}Error: Unknown command '$1'${NC}"
        echo ""
        print_help
        exit 1
        ;;
esac