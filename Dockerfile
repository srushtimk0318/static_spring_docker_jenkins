# -------- Stage 1: Build the app --------
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app

COPY pom.xml .
COPY src ./src

RUN mvn clean package -DskipTests

# -------- Stage 2: Runtime Image --------
FROM eclipse-temurin:21-jdk
WORKDIR /app

# Copy the JAR from build stage
COPY --from=build /app/target/*.jar app.jar

# Expose internal port
EXPOSE 8088

# Run Spring Boot app
ENTRYPOINT ["java", "-jar", "app.jar"]
