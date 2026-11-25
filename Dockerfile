FROM maven:3.9-eclipse-temurin-21 AS build

WORKDIR /app

COPY pom.xml .
RUN mvn -B -ntp dependency:go-offline

COPY src ./src

RUN mvn -B -ntp clean package -DskipTests


FROM eclipse-temurin:21-jre

WORKDIR /app

# Запуск без прав root.
RUN useradd --system --no-create-home appuser

COPY --from=build /app/target/task-manager-cicd-1.0.0.jar app.jar

USER appuser

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]