# Best Insurance API

This project is a Spring Boot application that can be built with Maven or Gradle.

## Prerequisites

- **JDK 17** or higher installed and available on your `PATH`.
- **Docker** installed and running to build container images.

## Building a container image

### Maven

```bash
./mvnw spring-boot:build-image -DskipTests -Dspring-boot.build-image.imageName=best_insurance/api
```

### Gradle

```bash
./gradlew bootBuildImage --imageName=best_insurance/api -x test
```

## Running with Docker Compose

First build the container image using either the Maven or Gradle command from the previous section. Once the image `best_insurance/api` is available, start all services with:

```bash
docker compose -f docker/docker-compose.yml up
```

Use `docker compose -f docker/docker-compose.yml down` to stop the containers. To remove the application image when you are done, run:

```bash
docker rmi best_insurance/api
```

