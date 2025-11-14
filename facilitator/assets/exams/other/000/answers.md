# Docker Speed Run - Core Concepts: Solutions

## Question 1: Create and tag a Docker image

**Task**: Create a Docker image named `docker-speedrun:v1` using the provided Dockerfile and tag it as `docker-speedrun:latest`.

**Solution**:
```bash
# Navigate to the directory containing the Dockerfile
cd /tmp/exam/q1

# Build the image with the tag docker-speedrun:v1
docker build -t docker-speedrun:v1 .

# Tag the image as docker-speedrun:latest
docker tag docker-speedrun:v1 docker-speedrun:latest

# Verify the images exist
docker images | grep docker-speedrun
```

## Question 2: Run a container with specific parameters

**Task**: Run a container using nginx:alpine with specific parameters.

**Solution**:
```bash
docker run -d --name web-server -p 8080:80 -e NGINX_HOST=localhost nginx:alpine

# Verify the container is running
docker ps | grep web-server

# Verify environment variable
docker exec web-server env | grep NGINX_HOST
```

## Question 3: Create and use a Docker volume

**Task**: Create a Docker volume and use it in a container to persist data.

**Solution**:
```bash
# Create the volume
docker volume create data-volume

# Run a container that mounts the volume and creates a file
docker run --name volume-test -v data-volume:/app/data alpine:latest sh -c "echo 'Docker volumes test' > /app/data/test.txt"

# Verify the data was persisted
docker run --rm -v data-volume:/app/data alpine:latest cat /app/data/test.txt
```

## Question 4: Create a multi-stage Dockerfile

**Task**: Create a multi-stage Dockerfile to build a Go application with a minimal final image.

**Solution**:
```
FROM golang:1.17-alpine AS builder
WORKDIR /app
COPY /tmp/exam/q4/main.go .
RUN go mod init example.com/goapp
RUN go build -o app .

FROM alpine:latest
WORKDIR /root/
COPY --from=builder /app/app .
ENTRYPOINT ["./app"]
```

Build command:
```bash
cd /tmp/exam/q4
docker build -t multi-stage:latest .
```

## Question 5: Create a custom network and use container DNS

**Task**: Create a custom bridge network and test container DNS resolution.

**Solution**:
```bash
# Create the custom network
docker network create --subnet=172.18.0.0/16 app-network

# Run the first container in detached mode
docker run -d --name app1 --network app-network alpine sleep 1000

# Run the second container to ping the first one
docker run --name app2 --network app-network alpine ping -c 3 app1

# Verify the containers used the correct network
docker network inspect app-network
```

## Question 6: Set container resource limits

**Task**: Run a container with CPU and memory limits.

**Solution**:
```bash
docker run -d --name limited-resources \
  --cpus=0.5 \
  --memory=256m \
  stress --cpu 1

# Verify the limits
docker inspect limited-resources --format '{{.HostConfig.NanoCpus}}'
docker inspect limited-resources --format '{{.HostConfig.Memory}}'
```

## Question 7: Create a Docker Compose configuration

**Task**: Create a Docker Compose file for a web and database application.

**Solution**:
```yaml
services:
  web:
    image: nginx:alpine
    ports:
      - "8081:80"
    networks:
      - app-network

  db:
    image: postgres:13
    environment:
      - POSTGRES_USER=dbuser
      - POSTGRES_PASSWORD=dbpassword
      - POSTGRES_DB=myapp
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - app-network

networks:
  app-network:
    driver: bridge

volumes:
  db-data:
```

Start services:
```bash
cd /tmp/exam/q7
docker compose up -d
```

## Question 8: Troubleshoot a container

**Task**: Fix an issue with a broken container.

**Solution**:
```bash
mkdir -p /tmp/exam/q13

# Check container logs
docker logs broken-container > /tmp/exam/q13/container-logs.txt

# Examine the container
docker rm broken-container

echo '{"k":"v"}' > config.json
docker run -d --name broken-container -v ./config.json:/app/config.json broken-app:latest
## note: ./config.json will work, but config.json alone will not work

```

## Question 9: Create a Docker container with non-root user

**Task**: Create a Dockerfile that runs as a non-root user for improved security.

**Solution**:
```
FROM python:3.9-slim

# Create a non-root user
RUN useradd -u 1001 -m appuser

# Set the working directory
WORKDIR /app

# Copy the application code
COPY /tmp/exam/q9/app.py .

# Change ownership to the non-root user
RUN chown -R appuser:appuser /app

# Switch to the non-root user
USER appuser

# Set the entrypoint
ENTRYPOINT ["python", "app.py"]
```

Build and run:
```bash
cd /tmp/exam/q9
docker build -t secure-app .
docker run -d --name secure-app secure-app

# Verify the user
docker exec secure-app whoami
```