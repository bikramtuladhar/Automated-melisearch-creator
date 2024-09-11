FROM ubuntu:latest

WORKDIR /meilisearch

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg netcat-traditional\
    lsb-release \
    wget && \
    rm -rf /var/lib/apt/lists/*

# Add Docker’s official GPG key
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the Docker repository
RUN echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker CLI
RUN apt-get update && \
    apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

# Download and install shell2http
RUN wget https://github.com/msoap/shell2http/releases/download/v1.17.0/shell2http_1.17.0_linux_amd64.deb && \
    dpkg -i shell2http_1.17.0_linux_amd64.deb && \
    rm shell2http_1.17.0_linux_amd64.deb

EXPOSE 8081
# Default command (optional, adjust as needed)

CMD ["shell2http", "-host=0.0.0.0", "-port=8081", "-500", "-form", "/create-meilisearch", "/meilisearch/main_script.sh \"up\" \"$v_jira_code\""]
