FROM openjdk:17-jdk-slim
# Set working directory
WORKDIR /app
# Copy the application JAR
COPY ./target/devguru-0.0.1-SNAPSHOT.jar app.jar
# Set environment variables
ENV SPRING_DATASOURCE_URL=jdbc:mysql://mysql-container:3306/myapplication?createDatabaseIfNotExist=true
ENV SPRING_DATASOURCE_USERNAME=root
ENV SPRING_DATASOURCE_PASSWORD=1234
# Expose port
EXPOSE 8081
# Start the application
ENTRYPOINT ["java", "-jar", "app.jar"]
