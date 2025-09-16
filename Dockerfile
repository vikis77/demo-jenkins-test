# SpringBoot Demo 916 Dockerfile
# Build with: docker build -t springboot-demo-916 .
# Run with: docker run -p 8080:8080 springboot-demo-916

FROM openjdk:17-jdk-slim

# Set working directory
WORKDIR /app

# Add metadata
LABEL maintainer="springboot-demo-916"
LABEL version="1.0.0"
LABEL description="SpringBoot 3 + JDK 17 Demo Application"

# Copy JAR file
COPY target/springboot-demo-916.jar app.jar

# Create non-root user for security
RUN addgroup --system spring && adduser --system spring --ingroup spring
RUN chown spring:spring app.jar
USER spring:spring

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080 || exit 1

# Start application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]