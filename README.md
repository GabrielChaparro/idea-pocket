# IdeaPocket

Personal inbox for quick ideas, notes, and tasks.

## Stack

- Backend: Java 21, Spring Boot, REST, JWT
- App: Flutter for mobile and web
- Database: PostgreSQL

## Local Start

1. Start PostgreSQL:

```bash
docker compose up -d db
```

2. Run the backend:

```bash
cd backend
mvn spring-boot:run
```

3. Run Flutter:

```bash
cd app
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080/api
```

The backend defaults are defined in `backend/src/main/resources/application.yml`.

## Local CORS

For development, the backend accepts Flutter Web origins matching:

```text
http://localhost:*
http://127.0.0.1:*
```

Override this with:

```bash
CORS_ALLOWED_ORIGIN_PATTERNS=https://your-domain.com
```
