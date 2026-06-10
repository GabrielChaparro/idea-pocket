# Farodeck

Personal inbox for quick ideas, notes, and tasks.

## Stack

- Backend: Java 21, Spring Boot, REST, JWT
- App: Flutter for mobile and web
- Database: PostgreSQL
- Tests: JUnit/MockMvc/H2 for backend, Flutter widget tests

## Project Structure

```text
.
├── backend/        # Spring Boot API
├── app/            # Flutter mobile/web app
├── docker-compose.yml
└── README.md
```

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
flutter run -d chrome --web-port 3000 --dart-define=API_BASE_URL=http://127.0.0.1:8080/api
```

The backend defaults are defined in `backend/src/main/resources/application.yml`.

## Environment

Copy the examples when you need local overrides:

```bash
cp backend/.env.example backend/.env
cp app/.env.example app/.env
```

Do not commit real `.env` files.

Backend variables:

| Variable | Purpose | Local default |
| --- | --- | --- |
| `PORT` | API port | `8080` |
| `DATABASE_URL` | JDBC PostgreSQL URL | `jdbc:postgresql://localhost:5432/ideapocket` |
| `DATABASE_USER` | DB username | `ideapocket` |
| `DATABASE_PASSWORD` | DB password | `ideapocket` |
| `JWT_SECRET` | JWT signing secret | development placeholder |
| `JWT_EXPIRATION_MINUTES` | Access token duration | `60` |
| `CORS_ALLOWED_ORIGIN_PATTERNS` | Allowed web origins | `http://localhost:*,http://127.0.0.1:*` |

Flutter variable:

| Variable | Purpose | Local default |
| --- | --- | --- |
| `API_BASE_URL` | REST API URL used by Flutter | `http://localhost:8080/api` |

Flutter reads `API_BASE_URL` at compile time through `--dart-define`.

## Tests

Backend:

```bash
cd backend
mvn test
```

Flutter:

```bash
cd app
flutter analyze
flutter test
```

## Healthcheck

The backend exposes a public health endpoint:

```bash
curl http://localhost:8080/api/health
```

Example response:

```json
{
  "status": "UP",
  "application": "farodeck-api",
  "database": "UP",
  "time": "2026-06-02T10:00:00Z"
}
```

## Build

Flutter Web:

```bash
cd app
flutter build web --pwa-strategy=none --dart-define=API_BASE_URL=http://127.0.0.1:8080/api
```

Backend JAR:

```bash
cd backend
mvn package
```

Backend Docker image:

```bash
docker build -t farodeck-api ./backend
```

Run backend container against local PostgreSQL:

```bash
docker run --rm -p 8080:8080 \
  -e DATABASE_URL=jdbc:postgresql://host.docker.internal:5432/ideapocket \
  -e DATABASE_USER=ideapocket \
  -e DATABASE_PASSWORD=ideapocket \
  -e JWT_SECRET=replace-with-a-strong-secret-of-at-least-32-characters \
  -e CORS_ALLOWED_ORIGIN_PATTERNS=http://localhost:*,http://127.0.0.1:* \
  farodeck-api
```

## Deployment

### Backend

The backend is deployable as a Docker service using [backend/Dockerfile](backend/Dockerfile).

Recommended first deployment:

- API: Render or Railway.
- Database: managed PostgreSQL from the same provider, Neon, or Supabase.
- Healthcheck: `/api/health`.

Required backend environment variables in production:

```text
DATABASE_URL=jdbc:postgresql://...
JWT_SECRET=strong-secret-at-least-32-characters
JWT_EXPIRATION_MINUTES=60
CORS_ALLOWED_ORIGIN_PATTERNS=https://your-flutter-web-domain.com
```

`DATABASE_URL` may also be provided as a platform URL such as `postgres://user:password@host:5432/db`; the backend converts it to JDBC on startup.

There is an optional Render blueprint in [render.yaml](render.yaml). Before using it, replace:

```text
https://your-flutter-web-domain.example.com
```

with the real Flutter Web domain.

### Flutter Web

Build the app with the deployed backend URL:

```bash
cd app
flutter build web --pwa-strategy=none --dart-define=API_BASE_URL=https://your-api-domain.com/api
```

Deploy `app/build/web` to a static hosting provider:

- Cloudflare Pages
- Netlify
- Vercel
- Firebase Hosting

For Cloudflare Pages, a simple setup is:

```text
Build command: cd app && flutter build web --pwa-strategy=none --dart-define=API_BASE_URL=https://your-api-domain.com/api
Build output directory: app/build/web
```

## Local CORS

For development, the backend accepts Flutter Web origins matching:

```text
http://localhost:*
http://127.0.0.1:*
```

Override this in deployed environments:

```bash
CORS_ALLOWED_ORIGIN_PATTERNS=https://your-domain.com
```

## Troubleshooting

Docker is not running:

```text
Cannot connect to the Docker daemon
```

Open Docker Desktop or start the Docker daemon, then run:

```bash
docker compose up -d db
```

CORS errors from Flutter Web:

- Restart the backend after changing CORS variables.
- Prefer matching hostnames:

```bash
flutter run -d chrome --web-port 3000 --dart-define=API_BASE_URL=http://127.0.0.1:8080/api
```

Database schema errors:

- Confirm PostgreSQL is running.
- Confirm credentials match `docker-compose.yml`.
- Flyway migrations live in `backend/src/main/resources/db/migration`.
