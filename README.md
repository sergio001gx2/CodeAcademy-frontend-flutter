# CodeAcademy - Aplicación Móvil en Flutter (Consumo de API Django)

Este proyecto es una aplicación móvil desarrollada en **Flutter** utilizando **Arquitectura Limpia (Clean Architecture)**. La aplicación consume una **API REST desarrollada en Django**, implementando autenticación mediante **JWT**, control de acceso basado en roles (**RBAC**) y una separación clara entre la parte pública y privada.

---

# 🎥 Demo del Proyecto

## Video Demostrativo Principal

**https://youtu.be/Kp0fPLNpl5c**

En este video se demuestra:

- Navegación por la sección pública.
- Inicio de sesión.
- Consumo de la API.
- Operaciones CRUD.
- Control de acceso por roles (Administrador, Docente y Estudiante).
- Manejo de sesiones con JWT.
- Funcionamiento general de la aplicación.

---

## Video Complementario

**https://youtu.be/IH08hAuo9H0**

Este video muestra un recorrido adicional por la aplicación y la arquitectura implementada.

---

## Repositorios y Documentación de la API

* **Repositorio del Backend:** https://github.com/sergio001g/CodeAcademy_bakend
* **API REST Base (Producción):** https://codeacademy-api.uaeftt-ute.site/api/
* **Documentación Swagger:** https://codeacademy-api.uaeftt-ute.site/api/docs/
* **Panel de Administración Django:** https://codeacademy-api.uaeftt-ute.site/admin/

---

## Requisitos del Sistema y Configuración

La aplicación consume directamente el backend de producción.

La URL base se encuentra centralizada en:

```
lib/core/config/app_config.dart
```

Para cambiar el servidor únicamente modifique la constante correspondiente.

---

# Credenciales de Prueba

| Rol | Email | Contraseña |
|------|-------|------------|
| Administrador | admin@codeacademy.com | admin123 |
| Docente | teacher@codeacademy.com | teacher123 |
| Estudiante | student@codeacademy.com | student123 |

### Permisos por Rol

### Administrador

- CRUD Usuarios
- CRUD Cursos
- CRUD Categorías
- Acceso al Panel Administrativo

### Docente

- Crear cursos
- Crear foros
- Crear evaluaciones
- Visualizar calificaciones
- Administrar sus cursos

### Estudiante

- Matricularse en cursos
- Completar lecciones
- Participar en foros
- Resolver cuestionarios
- Obtener certificados

---

# Funcionalidades Implementadas

## ✅ Autenticación JWT

- Login
- Registro
- Refresh Token
- Persistencia segura con flutter_secure_storage
- Interceptor Dio
- Logout automático al expirar la sesión

## ✅ Control de Acceso (RBAC)

- Administrador
- Docente
- Estudiante

Cada rol visualiza únicamente las opciones permitidas por el backend.

## ✅ Consumo de API REST

### Cursos

- Listado
- Detalle
- Crear
- Editar
- Eliminar

### Categorías

- Listado
- Crear
- Editar
- Eliminar

### Usuarios

- Listado
- Crear usuarios

### Foros

- Crear
- Listar
- Comentar

### Evaluaciones

- Resolver exámenes
- Ver resultados

---

# Manejo de Estado

- Provider
- ChangeNotifier

---

# Arquitectura

```
lib
│
├── core
├── data
├── domain
├── presentation
├── theme
└── main.dart
```

El proyecto implementa **Clean Architecture**, separando responsabilidades en capas independientes:

- Core
- Data
- Domain
- Presentation
- Theme

---

# Estructura del Proyecto

(Se mantiene toda la estructura de carpetas y archivos que ya tienes en el README.)

---

# Capturas de Pantalla

## 1. Pantalla Pública

> Agregar captura aquí

---

## 2. Pantalla de Login

> Agregar captura aquí

---

## 3. Dashboard Principal

> Agregar captura aquí

---

## 4. Consumo de API (Listado)

> Agregar captura aquí

---

## 5. CRUD Exitoso

> Agregar captura aquí

---

## 6. Restricción por Rol (RBAC)

> Agregar captura aquí

---

## 7. Perfil del Estudiante

> Agregar captura aquí

---

## 8. Panel del Docente

> Agregar captura aquí

---

## 9. Panel del Administrador

> Agregar captura aquí

---

## 10. Gestión de Cursos

> Agregar captura aquí

---

# Instalación

```bash
git clone <repositorio>

flutter pub get

flutter run
```

## Requisitos

- Flutter >= 3.0
- Dart compatible
- Android Studio o VS Code
- Emulador Android/iOS o dispositivo físico

---

# Tecnologías Utilizadas

- Flutter
- Dart
- Provider
- Dio
- JWT
- Flutter Secure Storage
- GoRouter
- Django REST Framework
- PostgreSQL
- Swagger/OpenAPI

---

# Autor

Proyecto desarrollado como entrega final de la materia de Desarrollo de Aplicaciones Móviles utilizando Flutter y Django REST Framework.
