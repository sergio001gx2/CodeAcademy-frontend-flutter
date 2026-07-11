# CodeAcademy - Aplicación Móvil en Flutter (Consumo de API Django)

Este proyecto es una aplicación móvil desarrollada en **Flutter** utilizando **Arquitectura Limpia (Clean Architecture)**. La app cumple con todos los requisitos del proyecto final, consumiendo una API REST desarrollada en Django, con secciones públicas y privadas protegidas por autenticación JWT y control de acceso basado en roles (RBAC).

## 🚀 Requisitos del Sistema y Configuración (URL de API)
La aplicación consume directamente el backend de producción. La configuración de la URL base se encuentra centralizada en `lib/core/config/app_config.dart`.

* **API REST Base (Producción):** `https://codeacademy-api.uaeftt-ute.site/api/`
* **Swagger Docs:** `https://codeacademy-api.uaeftt-ute.site/api/docs/`
* **Django Admin:** `https://codeacademy-api.uaeftt-ute.site/admin/`

---

## 🔑 Credenciales de Prueba (Garantizadas en Producción)

Para validar el control de acceso por roles, se han configurado cuentas de prueba reales en la API:

| Rol de Usuario | Correo Electrónico (Email) | Contraseña | Permisos y Reglas de Negocio (RBAC) |
|---|---|---|---|
| **ADMINISTRADOR** | `admin@codeacademy.com` | `admin123` | **(Parte Privada Admin)** Puede crear, editar y eliminar usuarios, cursos y categorías. Tiene un "Panel de Administración" visible exclusivo para su rol. |
| **DOCENTE** | `teacher@codeacademy.com` | `teacher123` | **(Parte Privada)** Solo puede ver sus propios cursos. Tiene permisos exclusivos para **crear nuevos foros y exámenes**. No puede rendir exámenes, en su lugar, el sistema le muestra las calificaciones de los estudiantes que ya rindieron. |
| **ESTUDIANTE** | `student@codeacademy.com` | `student123` | **(Parte Privada)** Puede matricularse en cursos, marcar lecciones como completadas, comentar en foros, y rendir exámenes. Se le bloquea cualquier acceso de creación/edición de cursos o cuestionarios. |

*(La parte pública es accesible sin iniciar sesión e incluye el Home, el Catálogo de Cursos y el Detalle del Curso).*

---

## 🏗️ Cumplimiento de Requerimientos Obligatorios

### 1. Autenticación y Manejo de Sesión (JWT)
- **Login y Registro:** Implementados consumiendo los endpoints `/auth/login/` y `/auth/register/`.
- **Persistencia Segura:** El token JWT se almacena de forma persistente y cifrada utilizando `flutter_secure_storage` en la capa local (`secure_storage.dart`).
- **Intercepción y 401:** Se utiliza `Dio` con el interceptor `AuthInterceptor` para adjuntar el token `Bearer` automáticamente en cada request. Si el token expira (Error 401), el interceptor intenta refrescarlo (`/auth/token/refresh/`), si falla, limpia la sesión y redirige al Login.
- **Rutas Protegidas:** Configurado en `app_router.dart` mediante `GoRouter`. Si el usuario no tiene token, es redirigido fuera de las rutas privadas (`/orders`, `/admin`, etc.).

### 2. Control de Acceso por Roles (RBAC)
- El rol se lee directamente desde los *claims* del token JWT decodificado en `jwt_decoder.dart` (`is_teacher`, `is_student`, `is_staff`).
- Las reglas de negocio determinan las vistas: El Admin ve un botón hacia el "Panel de Administración", el estudiante ve un atajo a "Mis Foros/Pruebas" y los botones de acción CRUD de foros se ocultan/muestran dependiendo si el usuario es Docente.

### 3. Consumo de API (Módulos CRUD)
Se consumen más de 2 módulos funcionales con operaciones completas:
1. **Módulo Cursos y Categorías:** 
   - *Público:* Listado (`/courses/`, `/categories/`) y Detalles de curso.
   - *Admin:* Creación, Edición y Eliminación desde el Panel Privado.
2. **Módulo Interactivo (Foros y Evaluaciones):** 
   - *Docente:* Crea cuestionarios y foros (`POST /quizzes/`, `POST /discussion-forums/`).
   - *Estudiante:* Detalle/Listado de Foros, envío de respuestas a exámenes (`POST /quiz-attempts/`).
3. **Módulo Usuarios (Admin):** Listado y creación de nuevos usuarios mediante el backend (`/users/`).

### 4. Manejo de Estados y UX
- **Estados:** Manejados mediante `Provider` y `ChangeNotifier`.
- **UX:** Uso de `LoadingOverlay` y `CircularProgressIndicator` para peticiones en red. Validaciones de regex en formularios. Mensajes de éxito y error mediante `ScaffoldMessenger` (SnackBar) leyendo las excepciones centralizadas en `ApiException`.

---

## 📁 Estructura del Proyecto (Arquitectura Limpia)
El código fuente respeta la estructura recomendada `data`, `domain`, `presentation`, `core` y `theme`:

```text
lib/
├── core/
│   ├── config/app_config.dart          ← URL Base
│   ├── error/api_exception.dart        ← Excepciones
│   └── utils/validators.dart
├── data/
│   ├── local/secure_storage.dart       ← wrapper de FlutterSecureStorage
│   ├── remote/
│   │   ├── api/dio_client.dart         ← instancia Dio
│   │   ├── dto/category_dto.dart, etc.
│   │   └── interceptor/auth_interceptor.dart
│   └── repository/
│       ├── auth_repository_impl.dart
│       ├── catalog_repository_impl.dart
│       ├── order_repository_impl.dart
│       └── admin_repository_impl.dart
├── domain/
│   ├── model/user.dart, course.dart, etc.
│   └── repository/auth_repository.dart, etc.
├── presentation/
│   ├── navigation/app_router.dart      ← GoRouter con guards (RBAC)
│   ├── providers/auth_provider.dart, etc.
│   ├── screens/
│   │   ├── auth/login_screen.dart, etc.
│   │   ├── catalog/catalog_screen.dart, forum_screen.dart, quiz_screen.dart
│   │   └── admin/admin_users_screen.dart, etc.
│   └── widgets/loading_overlay.dart, etc.
└── theme/app_theme.dart, app_colors.dart
```

---

## 📸 Evidencia Funcional (Capturas y Video)

*(Debes reemplazar estos apartados con tus capturas y el link del video)*

**Enlace al Video Demostrativo (3 - 5 min):** 
👉 `[INSERTAR_AQUÍ_LINK_A_YOUTUBE_O_DRIVE]` 

En el video se demuestra:
1. Navegación en la Parte Pública (Catálogo).
2. Login de Estudiante, restricciones de rol y consumo de Exámenes/Foros.
3. Login de Docente y visualización de Notas de alumnos (Regla de negocio).
4. Login de Administrador, acceso a parte privada y Creación/Listado de Usuarios o Cursos (CRUD).

### Capturas Obligatorias

1. **Pantalla Pública Principal:** `[AGREGAR IMAGEN]`
2. **Pantalla de Login:** `[AGREGAR IMAGEN]`
3. **Pantalla Principal Privada (Dashboard Admin):** `[AGREGAR IMAGEN]`
4. **Listado Consumiendo API (Ej: Lista de Usuarios o Cursos en Admin):** `[AGREGAR IMAGEN]`
5. **Formulario Creando con éxito (Ej: Cuestionario, Foro o Nuevo Usuario):** `[AGREGAR IMAGEN]`
6. **Restricción por Rol (Ej: Botones ocultos para estudiantes o acceso denegado):** `[AGREGAR IMAGEN]`

---

## 🔧 Instalación y Ejecución Local

1. Instala el SDK de Flutter (`>= 3.0.0`).
2. Clona el repositorio y navega al directorio del proyecto.
3. Ejecuta los siguientes comandos:
```bash
flutter pub get
flutter run
```
4. Se recomienda usar un Emulador Android para realizar las pruebas.
