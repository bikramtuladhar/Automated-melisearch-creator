#!/bin/bash

set -e

# Extract the port number from the script's filename
FILENAME=$(basename "$0")
PORT=${FILENAME##*-}
PORT=${PORT%.sh}

COMPOSE_FILE="docker-compose-${PORT}.yml"

# Function to display help menu
function display_help {
  echo "Usage: $0 {up|down|link|stop|delete|help} [PORT]"
  echo "Commands:"
  echo "  up [PORT]      - Start the Meilisearch container on the specified port"
  echo "  down [PORT]    - Stop and remove the Meilisearch container on the specified port"
  echo "  link [PORT]    - Create a symbolic link to the script with the specified port"
  echo "  stop [PORT]    - Stop the Meilisearch container without removing data"
  echo "  delete [PORT]  - Delete all Meilisearch-related files and directories"
  echo "  help           - Display this help menu"
  exit 0
}

# Function to start the Meilisearch container
function start_meilisearch {
  echo "Starting Meilisearch container on port ${PORT}..."

  # Check if data directory exists
  if [ -d "./data_meili_${PORT}" ]; then
    echo "Data directory exists: ./data_meili_${PORT}"

    # Check if container is stopped
    if docker compose -f ${COMPOSE_FILE} --project-name=${PORT} ps -q | grep -q .; then
      echo "Meilisearch container is already running on port ${PORT}"
    else
      echo "Meilisearch container is not running"

      # Prompt to start container using existing data
      echo "Do you want to start the container using the existing data? (y/n)"
      read -r start_existing
      if [[ "$start_existing" != "y" ]]; then
        echo "Operation cancelled. You can manually delete the data directory and start again."
        exit 0
      fi

      docker compose -f ${COMPOSE_FILE} --project-name=${PORT} up -d
      echo "Meilisearch container started on port ${PORT} using existing data"
      exit 0
    fi

  else
    # Create the data directory if it doesn't exist
    mkdir -p ./data_meili_${PORT}
    echo "Created data directory: ./data_meili_${PORT}"
  fi
  
  # Copy the template and replace the placeholder with the actual port number
  sed "s/\${PORT}/${PORT}/g" docker-compose-template.yml > ${COMPOSE_FILE}
  echo "Generated Docker Compose file: ${COMPOSE_FILE}"
  
  # Run the Docker Compose file
  docker compose -f ${COMPOSE_FILE} --project-name=${PORT} up -d
  echo "Meilisearch container started on port ${PORT}"
}

# Function to stop the Meilisearch container
function stop_meilisearch {
  echo "Stopping Meilisearch container on port ${PORT}..."
  
  # Stop the Docker Compose services
  docker compose -f ${COMPOSE_FILE} --project-name=${PORT} stop
  echo "Meilisearch container stopped"
}

# Function to stop and remove the Meilisearch container
function down_meilisearch {
  echo "Are you sure you want to stop and remove the Meilisearch container on port ${PORT}? (y/n)"
  read -r confirmation
  if [[ "$confirmation" != "y" ]]; then
    echo "Operation cancelled."
    exit 0
  fi

  echo "Stopping and removing Meilisearch container on port ${PORT}..."
  
  # Stop and remove the Docker Compose services
 if [ -f ${COMPOSE_FILE} ]; then
  docker compose -f ${COMPOSE_FILE} --project-name=${PORT} down
  echo "Meilisearch container stopped and removed"
 else
   echo "Docker Compose file does not exist: ${COMPOSE_FILE}"
 fi

  # Remove the data directory
  if [ -d "./data_meili_${PORT}" ]; then
    sudo rm -rf ./data_meili_${PORT}
    echo "Removed data directory: ./data_meili_${PORT}"
  else
    echo "Data directory does not exist: ./data_meili_${PORT}"
  fi
  
  # Remove the generated Docker Compose file
  if [ -f ${COMPOSE_FILE} ]; then
    rm -f ${COMPOSE_FILE}
    echo "Removed Docker Compose file: ${COMPOSE_FILE}"
  else
    echo "Docker Compose file does not exist: ${COMPOSE_FILE}"
  fi

  # Self-destruct the script
  SCRIPT_NAME=$(basename "$0")
  echo "Self-destructing the script: ${SCRIPT_NAME}"
  rm -f "$0"
  echo "Script self-destructed."

}

# Function to delete all Meilisearch-related files and directories
function delete_meilisearch {
  echo "Are you sure you want to delete all Meilisearch-related files and directories? (y/n)"
  read -r confirmation
  if [[ "$confirmation" != "y" ]]; then
    echo "Operation cancelled."
    exit 0
  fi

  # Remove all data directories
  for dir in ./data_meili_*; do
    if [ -d "$dir" ]; then
      sudo rm -rf "$dir"
      echo "Removed data directory: $dir"
    fi
  done

  # Remove all Docker Compose files
  for file in docker-compose-*.yml; do
    if [ -f "$file" ]; then
      rm -f "$file"
      echo "Removed Docker Compose file: $file"
    fi
  done

  echo "All Meilisearch-related files and directories deleted."
}

# Function to create a symbolic link
function create_symlink {
  if [ -z "$1" ]; then
    echo "Error: No port specified for creating the symbolic link"
    display_help
  fi
  
  SYMLINK="meilisearch-$1.sh"
  ln -s "$(basename "$0")" "${SYMLINK}"
  echo "Created symbolic link: ${SYMLINK} -> $(basename "$0")"
}

# Check the command provided (up, down, link, stop, delete, or help)
case "$1" in
  up)
    if [ -n "$2" ]; then
      PORT=$2
    fi
    start_meilisearch
    ;;
  down)
    if [ -n "$2" ]; then
      PORT=$2
    fi
    down_meilisearch
    ;;
  link)
    if [ -n "$2" ]; then
      create_symlink $2
    else
      echo "Error: No port specified for creating the symbolic link"
      display_help
    fi
    ;;
  stop)
    if [ -n "$2" ]; then
      PORT=$2
    fi
    stop_meilisearch
    ;;
  delete)
    delete_meilisearch
    ;;
  help)
    display_help
    ;;
  *)
    echo "Invalid command"
    display_help
    ;;
esac