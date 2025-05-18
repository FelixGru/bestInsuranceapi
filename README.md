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

### Checking the logs

During startup, ensure there are no errors. Liquibase should report that its
changeset executed successfully. Look for a line similar to:

```
INFO ... liquibase.changelog: ChangeSet db/changelog/001-ddl-definition.sql::001-ddl-definition.sql::jpa_dev ran successfully in 80ms
```

If you see connection errors instead, verify that the `db` service is running
and that the environment variables in `docker-compose.yml` match the database
configuration.

## Inspecting the database

The `db` service exposes PostgreSQL on port `5432` and `adminer` is
available at `http://localhost:8081`.

Connect using any database client (e.g. **psql**, **DBeaver**, or a
browser for Adminer) with these settings:

- **Host:** `localhost`
- **Port:** `5432`
- **Database:** `best_insurance`
- **Username:** `bestinsurance`
- **Password:** `bestinsurance`

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

