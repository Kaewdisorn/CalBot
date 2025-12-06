#!/bin/bash

set -e

# Colors
INFO='\033[0;36m'
SUCCESS='\033[0;32m'
ERROR='\033[0;31m'
GRAY='\033[0;90m'
NC='\033[0m'


# Arguments
STACK_FILE=./database/postgres-stack.yml
STACK_NAME="calbotstack"
ENV_FILE="./.env"


# Check arguments
if [ -z "$STACK_FILE" ] || [ -z "$STACK_NAME" ]; then
    echo -e "${ERROR}[ERROR]${NC} Usage: $0 <stack-file> <stack-name> [env-file]"
    exit 1
fi

# Check if stack file exists
if [ ! -f "$STACK_FILE" ]; then
    echo -e "${ERROR}[ERROR]${NC} Stack file not found: $STACK_FILE"
    exit 1
fi

# Check if env file exists
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${ERROR}[ERROR]${NC} Env file not found: $ENV_FILE"
    exit 1
fi

# Load environment variables
echo -e "${INFO}[INFO]${NC} Loading environment from: $ENV_FILE"
while IFS= read -r line; do
    # Skip comments and empty lines
    if [[ $line =~ ^[[:space:]]*# ]] || [[ -z $line ]]; then
        continue
    fi
    
    # Export variable
    if [[ $line =~ ^[[:space:]]*([^=]+)=(.+)$ ]]; then
        var_name=$(echo "${BASH_REMATCH[1]}" | xargs)
        var_value=$(echo "${BASH_REMATCH[2]}" | xargs)
        export "$var_name=$var_value"
        echo -e "${GRAY}  - $var_name${NC}"
    fi
done < "$ENV_FILE"

# Deploy stack
echo -e "${INFO}[INFO]${NC} Deploying stack: $STACK_NAME"
docker stack deploy -c "$STACK_FILE" "$STACK_NAME"

echo -e "${SUCCESS}[SUCCESS]${NC} Stack deployed successfully!"
echo -e "${INFO}[INFO]${NC} View services: docker stack services $STACK_NAME"
echo -e "${INFO}[INFO]${NC} View logs: docker service logs -f ${STACK_NAME}_<service-name>"