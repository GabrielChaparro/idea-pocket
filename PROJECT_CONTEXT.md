# IdeaPocket - Contexto Del Proyecto

## Objetivo

IdeaPocket es una app personal para capturar ideas, pendientes, notas rápidas y tareas desde web y móvil. La prioridad inicial es tener una herramienta simple, rápida y usable, evitando sobreingeniería pero dejando una base razonable para crecer.

## Stack

- Backend: Java 21, Spring Boot
- API: REST
- Autenticación: JWT
- Base de datos: PostgreSQL
- Migraciones: Flyway
- App móvil/web: Flutter
- Repo: monorepo con `backend/` y `app/`

## Estructura Actual

```text
.
├── backend/
│   ├── pom.xml
│   └── src/main/
│       ├── java/com/ideapocket/
│       │   ├── auth/
│       │   ├── common/
│       │   ├── config/
│       │   ├── item/
│       │   ├── security/
│       │   ├── tag/
│       │   └── user/
│       └── resources/
│           ├── application.yml
│           └── db/migration/V1__initial_schema.sql
├── app/
│   └── lib/
│       ├── auth/
│       ├── core/
│       ├── items/
│       ├── tags/
│       ├── app.dart
│       └── main.dart
│   └── .env.example
├── backend/
│   ├── Dockerfile
│   ├── .dockerignore
│   └── .env.example
├── app/
│   └── .dockerignore
├── docker-compose.yml
├── render.yaml
├── README.md
└── PROJECT_CONTEXT.md
```

## Qué Hay Implementado

### Backend

- Proyecto Spring Boot con Maven.
- Configuración PostgreSQL.
- Migración inicial con tablas:
  - `users`
  - `items`
  - `tags`
  - `item_tags`
- Autenticación:
  - `POST /api/auth/register`
  - `POST /api/auth/login`
  - `GET /api/auth/me`
- Seguridad JWT básica.
- Passwords con BCrypt.
- CRUD principal de items:
  - crear
  - listar
  - detalle
  - actualizar
  - eliminar con soft delete
  - completar
  - reabrir
- Tags:
  - listar
  - crear
  - eliminar
  - validación de duplicados con `409 Conflict`
- Filtros básicos en items:
  - tipo
  - estado
  - texto
  - tag
- Separación por capas simple:
  - controller
  - service
  - repository
  - domain/entity
  - DTOs
- Tests de integración con `MockMvc` y H2:
  - registro/login
  - email duplicado
  - contraseña corta con mensaje amigable
  - CRUD básico de items
  - completar/reabrir/delete
  - aislamiento por usuario
  - etiquetas duplicadas
  - filtro por etiqueta
- Serialización estable de páginas con `PageSerializationMode.VIA_DTO`.
- Healthcheck público `GET /api/health`:
  - estado general
  - nombre de app
  - estado de base de datos
  - timestamp
- Soporte de despliegue:
  - `backend/Dockerfile` multi-stage
  - conversión automática de URLs `postgres://...` / `postgresql://...` a JDBC
  - variables de entorno listas para producción

### Flutter

- Proyecto Flutter generado para Android, iOS y Web.
- Pantalla de login/registro.
- Persistencia simple del token con `shared_preferences`.
- Listado de items.
- Búsqueda.
- Filtros por tipo y completadas.
- Captura rápida con selector:
  - Idea
  - Nota
  - Tarea
- Edición de registros existentes.
- Selector de prioridad en creación/edición.
- Gestión visual básica de etiquetas:
  - listar
  - crear
  - eliminar
  - asignar a registros
  - filtrar por etiqueta
- Confirmación antes de borrar registros y etiquetas.
- Filtro rápido de pendientes.
- Fechas límite para tareas desde Flutter.
- Filtros de fecha:
  - Hoy
  - Vencidas
- Backend permite filtrar items por `dueFrom` y `dueTo`.
- Orden seleccionable:
  - recientes
  - vencimiento
  - prioridad
- Backend soporta `order=CREATED_DESC|DUE_ASC|PRIORITY_DESC`.
- Botón para limpiar filtros activos.
- Estado vacío diferenciado para filtros sin resultados.
- Completar/reabrir items.
- Eliminar items.
- Frontend modularizado:
  - `core`: configuración, tema y API client
  - `auth`: sesión y login/registro
  - `items`: modelos, listado, editor y tarjeta
  - `tags`: modelo y diálogo de gestión
- Manejo visual de errores de API:
  - parseo de `message` del backend
  - estado de error/reintento en listado
  - errores visibles en login, editor y etiquetas
  - snackbars para acciones sobre items
- Estilo visual retro handheld:
  - paleta azul/mint/ámbar
  - tipografía monoespaciada
  - paneles con borde marcado y sombra dura
  - pantalla principal tipo consola portátil
  - tarjetas y modales adaptados al mismo lenguaje visual
- Consumo de API REST configurable con:

```bash
--dart-define=API_BASE_URL=http://localhost:8080/api
```

### Infraestructura Local

- `docker-compose.yml` con PostgreSQL 16.
- `README.md` con comandos de arranque, tests, builds, despliegue, variables y troubleshooting.
- `backend/.env.example` con variables del API.
- `app/.env.example` con `API_BASE_URL`.
- `backend/Dockerfile` para empaquetar la API.
- `.dockerignore` en backend y Flutter para excluir builds, `.env` y archivos locales.
- `render.yaml` como blueprint opcional para desplegar API + PostgreSQL en Render.
- Git inicializado en rama `main`.

## Verificación Realizada

Backend:

```bash
cd backend
mvn test
```

Resultado: correcto. Actualmente ejecuta 9 tests de integración.

Flutter:

```bash
cd app
flutter pub get
flutter analyze
flutter test
flutter build web --dart-define=API_BASE_URL=http://localhost:8080/api
```

Resultado: correcto.

Docker:

```bash
docker build -t ideapocket-api ./backend
```

Resultado: correcto. Se generó la imagen local `ideapocket-api:latest`.

## Cómo Arrancar

Base de datos:

```bash
docker compose up -d db
```

Backend:

```bash
cd backend
mvn spring-boot:run
```

Flutter Web:

```bash
cd app
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080/api
```

## Decisiones Tomadas

- Usar una única entidad `Item` para ideas, notas y tareas.
- Diferenciar con enum `ItemType`: `IDEA`, `NOTE`, `TASK`.
- Mantener estados simples: `ACTIVE`, `COMPLETED`.
- Usar tags flexibles en vez de categorías rígidas.
- Soft delete en items mediante `deleted_at`.
- API REST simple antes de añadir complejidad.
- JWT básico para MVP, con margen para refresh tokens más adelante.
- Flutter usa una separación simple por feature sin introducir gestión de estado pesada todavía.
- CORS en desarrollo permite `http://localhost:*` y `http://127.0.0.1:*` porque Flutter Web puede usar puertos dinámicos.

## Dónde Me Quedo

El proyecto tiene una primera base funcional creada. El backend compila, pasa tests y puede empaquetarse como imagen Docker. La app Flutter tiene una interfaz conectada a la API REST y pasa análisis, test inicial y build web. El despliegue inicial queda preparado a nivel de Dockerfile, healthcheck, variables y documentación.

## Siguiente Trabajo Recomendado

1. Ejecutar una prueba end-to-end local con PostgreSQL + backend + Flutter Web.
2. Probar manualmente:
   - registro
   - login
   - creación de item
   - listado
   - completar tarea
   - eliminar item
3. Publicar backend en Render/Railway con PostgreSQL gestionado.
4. Publicar Flutter Web en Cloudflare Pages, Netlify, Vercel o Firebase Hosting.
5. Actualizar `CORS_ALLOWED_ORIGIN_PATTERNS` con el dominio real de Flutter Web.
6. Introducir Riverpod si la UI empieza a compartir más estado entre pantallas.
7. Añadir vista de detalle más rica para notas largas.

## Riesgos / Deuda Técnica Actual

- JWT no tiene refresh token todavía.
- En Flutter Web se guarda token en `shared_preferences`; para producción convendría revisar estrategia con cookies httpOnly o endurecer seguridad.
- No hay modo offline.
- No hay gestión de estado formal; si crece la UI, conviene introducir Riverpod.
- El blueprint `render.yaml` contiene un dominio placeholder para CORS y debe ajustarse antes de usarlo en producción.

## Regla De Trabajo

Siempre que se hagan cambios relevantes en el proyecto, actualizar este archivo con:

- Qué se cambió.
- Qué quedó verificado.
- Dónde queda el trabajo.
- Qué falta hacer después.
