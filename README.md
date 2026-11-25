# task-manager-cicd

Учебное REST-приложение «Task Manager» для лабораторных работ по CI:
№ 1 — Jenkins (`Jenkinsfile`), № 2 — GitHub Actions (`.github/workflows/ci.yml`, добавляется во второй работе).

## Стек
Java 21 · Spring Boot 3.5.x · Maven · JUnit 5 · Spring Boot Test · Surefire / Failsafe · JaCoCo

## Сборка и тесты
```
mvn -B -ntp clean verify
```
Ожидаемый результат: 14 модульных (`*Test`, Surefire) + 11 интеграционных (`*IT`, Failsafe) = 25 тестов, 0 ошибок.

Результаты:
- `target/task-manager-cicd-1.0.0.jar` — исполняемый JAR
- `target/surefire-reports/`, `target/failsafe-reports/` — XML-отчёты
- `target/site/jacoco/index.html` — отчёт покрытия

## Запуск
```
java -jar target/task-manager-cicd-1.0.0.jar
```

## REST API (`/api/tasks`)
| Метод | URL | Описание |
|---|---|---|
| GET | `/api/tasks[?priority=LOW\|NORMAL\|HIGH]` | список задач / фильтр по приоритету |
| GET | `/api/tasks/{id}` | задача по ID |
| POST | `/api/tasks` | создать (`title`, `description`, `priority` — необязательный) |
| PATCH | `/api/tasks/{id}/status` | сменить статус (`NEW`, `IN_PROGRESS`, `DONE`) |
| PATCH | `/api/tasks/{id}/priority` | сменить приоритет |
| DELETE | `/api/tasks/{id}` | удалить |
