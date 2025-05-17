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

Build the image first with Maven or Gradle:

```bash
./mvnw spring-boot:build-image -DskipTests -Dspring-boot.build-image.imageName=best_insurance/api
# or
./gradlew bootBuildImage --imageName=best_insurance/api -x test
```

Start the services:

```bash
docker-compose -f docker/docker-compose.yml up
```

Stop the services when done:

```bash
docker-compose -f docker/docker-compose.yml down
```

To clean up the image:

```bash
docker rmi best_insurance/api
```

You may also run `docker image prune` to remove dangling images.
