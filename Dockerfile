# ============================
#   Stage 1: Build the Spring Boot app
# ============================
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY src ./src
RUN mvn clean package -DskipTests

# ============================
#   Stage 2: Run the Spring Boot app
# ============================
FROM eclipse-temurin:17-jdk
WORKDIR /app

COPY --from=build /app/target/devguru-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8088

ENTRYPOINT ["java", "-jar", "app.jar"]
