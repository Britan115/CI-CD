# syntax=docker/dockerfile:1

FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /workspace

COPY pom.xml .
RUN mvn -B dependency:go-offline

COPY src ./src
RUN mvn -B -DskipTests package

FROM eclipse-temurin:17-jre
WORKDIR /app

COPY --from=build /workspace/target/app-refcard-01-0.0.1-SNAPSHOT.jar app-refcard.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app-refcard.jar"]

