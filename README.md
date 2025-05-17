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

## Troubleshooting "No such image" errors

If `docker compose` reports that `best_insurance/api:latest` cannot be found
even though `docker images` lists it with an implausible creation date
(for example "45 years ago"), the image metadata is likely corrupted.
Remove the affected images and rebuild the application image:

```bash
docker rmi <IMAGE_ID_OF_best_insurance_api>
docker rmi <IMAGE_ID_OF_paketobuildpacks_builder>
./gradlew bootBuildImage --imageName=best_insurance/api
```

After rebuilding, run the compose command again:

```bash
docker compose -f docker/docker-compose.yml up
```

