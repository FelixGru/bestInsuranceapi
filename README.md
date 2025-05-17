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

