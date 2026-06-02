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
├── docker-compose.yml
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
- Consumo de API REST configurable con:

```bash
--dart-define=API_BASE_URL=http://localhost:8080/api
```

### Infraestructura Local

- `docker-compose.yml` con PostgreSQL 16.
- `README.md` con comandos mínimos de arranque.
- Git inicializado en rama `main`.

## Verificación Realizada

Backend:

```bash
cd backend
mvn test
```

Resultado: correcto. Actualmente ejecuta 6 tests de integración.

Flutter:

```bash
cd app
flutter pub get
flutter analyze
flutter test
flutter build web --dart-define=API_BASE_URL=http://localhost:8080/api
```

Resultado: correcto.

No se pudo levantar el entorno completo porque Docker no está activo:

```bash
docker compose up -d db
```

Resultado: `Cannot connect to the Docker daemon`.

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

El proyecto tiene una primera base funcional creada. El backend compila. La app Flutter tiene una primera interfaz conectada a la API REST y pasa análisis, test inicial y build web.

No hay todavía una ejecución end-to-end validada con backend + PostgreSQL + Flutter interactuando en navegador porque Docker no está arrancado en la máquina.

## Siguiente Trabajo Recomendado

1. Abrir Docker Desktop o arrancar el daemon de Docker.
2. Ejecutar PostgreSQL con Docker.
3. Levantar backend y confirmar que Flyway crea el esquema.
4. Probar manualmente:
   - registro
   - login
   - creación de item
   - listado
   - completar tarea
   - eliminar item
5. Crear `.env.example` o documentación de variables.
6. Añadir confirmación antes de borrar items/etiquetas.
7. Introducir Riverpod si la UI empieza a compartir más estado entre pantallas.

## Riesgos / Deuda Técnica Actual

- JWT no tiene refresh token todavía.
- En Flutter Web se guarda token en `shared_preferences`; para producción convendría revisar estrategia con cookies httpOnly o endurecer seguridad.
- No hay modo offline.
- No hay gestión de estado formal; si crece la UI, conviene introducir Riverpod.

## Regla De Trabajo

Siempre que se hagan cambios relevantes en el proyecto, actualizar este archivo con:

- Qué se cambió.
- Qué quedó verificado.
- Dónde queda el trabajo.
- Qué falta hacer después.
