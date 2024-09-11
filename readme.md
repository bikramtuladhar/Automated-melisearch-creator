### Meilisearch Docker Orchestration

This project provides a set of Docker resources to manage Meilisearch containers across different ports. You can use this repository to run multiple instances of Meilisearch, each isolated by its port, while simplifying the orchestration via Docker Compose. Additionally, it includes a shell2http utility to trigger container orchestration via HTTP.

#### Contents:
- **docker-compose-template.yml**: Template for creating individual Docker Compose files for each Meilisearch instance.
- **docker-compose.yml**: For managing the shell2http server that listens for HTTP requests to start/stop Meilisearch instances.
- **Dockerfile**: Defines the environment for the shell2http service and installs the necessary tools like Docker CLI.
- **main_script.sh**: A utility script for creating, starting, stopping, and removing Meilisearch containers based on the specified port.
  
---

### Setup Instructions

1. **Prerequisites**:
   - Docker installed on your system
   - Docker Compose installed on your system

2. **Build the shell2http service**:

   Clone the repository and navigate to the directory:

   Build the Docker image for the shell2http service:

   ```bash
   docker-compose build
   ```

   Start the shell2http service:

   ```bash
   docker-compose up -d
   ```

   The service will be available on `http://localhost:8081` and will listen for HTTP requests to trigger Meilisearch container operations.

---

### Managing Meilisearch Instances

Meilisearch containers are managed through the `main_script.sh` script, which accepts multiple commands for controlling Meilisearch instances on different ports.

#### 1. **Start a Meilisearch instance**:

```bash
./meilisearch.sh 7700 up
```

This command will:
- Start the Meilisearch container on port 7700.
- Create a data directory named `./data_meili_7700`.

#### 2. **Stop a Meilisearch instance**:

```bash
./meilisearch.sh 7700 stop
```

This will stop the running Meilisearch container without removing the data.

#### 3. **Remove a Meilisearch instance**:

```bash
./meilisearch.sh 7700 down
```

This command stops the container and removes all related data and Docker Compose files for port 7700.

#### 4. **Delete all Meilisearch instances**:

To remove all Meilisearch-related files and directories, use the delete command:

```bash
./meilisearch.sh 7700 delete
```

#### 5. **Create symbolic links for easier access**:

You can create symbolic links to quickly control Meilisearch instances on different ports:

```bash
./meilisearch.sh link 7700
```

This will create a symlink, `meilisearch.sh 7700`, that you can use to directly manage the instance.

---


### Notes

- The default Meilisearch master key is set in the `docker-compose-template.yml` file, but you can customize it as needed.
- Ensure Docker Compose files are appropriately generated for each instance before running the containers.
  
Feel free to adapt and extend this setup to suit your project needs!

