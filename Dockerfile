# Build stage
FROM amazoncorretto:21-alpine AS build
WORKDIR /app

# Install Gradle
RUN apk add --no-cache bash
COPY gradlew ./
COPY gradle ./gradle
RUN chmod +x gradlew

COPY build.gradle settings.gradle ./
COPY src ./src
RUN ./gradlew build copyOtelAgent -x test --no-daemon

# Runtime stage
FROM amazoncorretto:21-alpine
WORKDIR /app

# Create non-root user for security
RUN addgroup -g 1001 appgroup && adduser -u 1001 -G appgroup -D appuser

COPY --from=build /app/build/libs/*.jar app.jar
COPY --from=build /app/build/otel/aws-opentelemetry-agent-*.jar aws-opentelemetry-agent.jar

# Switch to non-root user
USER appuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/sentinel/actuator/health || exit 1

ENTRYPOINT ["java", "-javaagent:aws-opentelemetry-agent.jar", "-jar", "app.jar"]
