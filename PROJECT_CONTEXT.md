# Farodeck - Contexto Del Proyecto

## Objetivo

Farodeck es una app personal para capturar ideas, pendientes, notas rápidas y tareas desde web y móvil. La prioridad inicial es tener una herramienta simple, rápida y usable, evitando sobreingeniería pero dejando una base razonable para crecer.

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
- Marca pública actual: Farodeck.
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
- Nombre visible de la app actualizado a Farodeck en web, Android, iOS y UI Flutter.
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
- Estilo visual retro arcade:
  - paleta night/violeta/cyan/pink/ámbar/mint
  - tipografía monoespaciada
  - paneles con borde marcado y sombra dura
  - pantalla principal tipo arcade capture deck
  - tarjetas con acento por tipo de registro
  - modales adaptados al mismo lenguaje visual
- Ajustes visuales recientes:
  - campos de texto forzados a tipografía monoespaciada
  - cursor/selección/labels de inputs alineados con el estilo retro
  - control de orden reemplazado por botones tipo chip retro
  - botón Capturar reemplazado por botón arcade propio
  - logo generado descartado por ahora porque no encajaba y el nombre puede cambiar
  - marca pública actualizada a Farodeck
- Funciones recientes de producto en Flutter:
  - captura rápida tipo consola
  - parser simple para `tarea:`, `nota:`, `idea:`, `#tag`, `!alta`, `!media`, `!baja`, `hoy` y `mañana`
  - Vista Hoy con grupos `VENCIDAS`, `PARA HOY` y `SIN FECHA`
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
- `app/web/_headers` para Netlify, evitando cache agresivo en builds web.
- Git inicializado en rama `main`.

### Despliegue Actual

- Backend desplegado en Render:

```text
https://idea-pocket.onrender.com
```

- Healthcheck validado:

```text
https://idea-pocket.onrender.com/api/health
```

- Resultado observado:
  - API `UP`
  - database `UP`
  - registro/login funcionan
  - creación/listado de items funciona

- Flutter Web desplegado en Netlify:

```text
https://lambent-cat-6c27e2.netlify.app/
```

- CORS en Render fue actualizado manualmente para permitir:

```text
https://lambent-cat-6c27e2.netlify.app
```

- Netlify funciona en móvil y Safari.
- En Chrome/Chromium de escritorio hubo un problema visual al escribir: el texto no se veía hasta perder foco y parecía que la página se repintaba. Se confirmó que al desactivar la aceleración gráfica de Chrome el problema desaparece, aunque queda más lento. Diagnóstico: problema de render/GPU de Chrome con Flutter Web, no backend/CORS.

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
flutter build web --pwa-strategy=none --dart-define=API_BASE_URL=http://localhost:8080/api
```

Resultado: correcto.

Docker:

```bash
docker build -t farodeck-api ./backend
```

Resultado: correcto. Se generó la imagen local `farodeck-api:latest`.

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
flutter run -d chrome --web-port 3000 --dart-define=API_BASE_URL=http://localhost:8080/api
```

Flutter Web contra backend desplegado:

```bash
cd app
flutter run -d chrome --web-port 3000 --dart-define=API_BASE_URL=https://idea-pocket.onrender.com/api
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
- Para Netlify se recomienda compilar con `--pwa-strategy=none` para evitar cache/service worker agresivo mientras la app evoluciona rápido.
- No se adoptó `--wasm` como solución: se probó, pero no resolvió el problema visual de Chrome escritorio. Mantener build web normal por ahora.
- El nombre público es Farodeck; los paquetes Java `com.ideapocket` y la base de datos local `ideapocket` se mantienen por ahora para evitar un renombrado invasivo sin valor funcional inmediato.

## Dónde Me Quedo

El proyecto tiene una primera base funcional creada y desplegada. El backend está en Render con PostgreSQL gestionado y el frontend está en Netlify. La app sirve para uso personal en su estado actual. El último corte de frontend movió la UI hacia una dirección retro arcade más viva, añadió captura rápida y Vista Hoy, y queda pendiente validar ese build en Netlify antes de commitear/desplegar como versión estable.

## Siguiente Trabajo Recomendado

1. Desplegar el build actual de Flutter Web en Netlify y validar visual/funcionalmente.
2. Usar la app 2-3 días como herramienta personal y anotar fricciones reales.
3. Mejorar captura rápida:
   - crear tags si no existen
   - detectar fechas con más precisión
   - confirmar lo interpretado antes de guardar en casos ambiguos
4. Añadir flujo de procesar inbox.
5. Añadir vista de detalle más rica para notas largas.
6. Introducir Riverpod solo si el estado empieza a crecer en varias pantallas.
7. Evaluar IA más adelante, empezando por sugerencias aceptables/rechazables, no automatización total.

## Riesgos / Deuda Técnica Actual

- JWT no tiene refresh token todavía.
- En Flutter Web se guarda token en `shared_preferences`; para producción convendría revisar estrategia con cookies httpOnly o endurecer seguridad.
- No hay modo offline.
- No hay gestión de estado formal; si crece la UI, conviene introducir Riverpod.
- El blueprint `render.yaml` contiene un dominio placeholder para CORS y debe ajustarse antes de usarlo en producción.
- Flutter Web en Chrome/Chromium escritorio puede presentar problemas visuales con aceleración gráfica activada. Safari y móvil funcionan bien. Para Chrome, desactivar aceleración gráfica evita el problema observado.
- La dirección visual retro arcade está en progreso y debe validarse en uso real antes de considerarla lista para una app pública.

## Regla De Trabajo

Siempre que se hagan cambios relevantes en el proyecto, actualizar este archivo con:

- Qué se cambió.
- Qué quedó verificado.
- Dónde queda el trabajo.
- Qué falta hacer después.
