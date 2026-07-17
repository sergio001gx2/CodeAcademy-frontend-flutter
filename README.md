# CodeAcademy - Aplicación Móvil en Flutter (Consumo de API Django)

Este proyecto es una aplicación móvil desarrollada en **Flutter** utilizando **Arquitectura Limpia (Clean Architecture)**. La aplicación cumple con todos los requisitos del proyecto final, consumiendo una API REST desarrollada en Django, con secciones públicas y privadas protegidas por autenticación JWT y control de acceso basado en roles (RBAC).

---

## Repositorios y Documentación de la API

* **Repositorio del Backend:** [CodeAcademy Backend Repository](https://github.com/sergio001g/CodeAcademy_bakend)
* **API REST Base (Producción):** [CodeAcademy API](https://codeacademy-api.uaeftt-ute.site/api/)
* **Documentación Swagger (Endpoints):** [Swagger Docs](https://codeacademy-api.uaeftt-ute.site/api/docs/)
* **Django Admin Panel:** [Django Admin](https://codeacademy-api.uaeftt-ute.site/admin/)

---

## Requisitos del Sistema y Configuración (URL de API)

La aplicación consume directamente el backend de producción. La configuración de la URL base se encuentra centralizada en el archivo `lib/core/config/app_config.dart`.

Para cambiar la URL base, simplemente modifique la constante del archivo de configuración correspondiente.

---

## Credenciales de Prueba (Garantizadas en Producción)

Para validar el control de acceso por roles, se han configurado cuentas de prueba reales en la API:

| Rol de Usuario | Correo Electrónico (Email) | Contraseña | Permisos y Reglas de Negocio (RBAC) |
|---|---|---|---|
| **ADMINISTRADOR** | admin@codeacademy.com | admin123 | *(Parte Privada Admin)* Puede crear, editar y eliminar usuarios, cursos y categorías. Tiene un Panel de Administración visible exclusivo para su rol. |
| **DOCENTE** | teacher@codeacademy.com | teacher123 | *(Parte Privada)* Solo puede ver sus propios cursos. Tiene permisos exclusivos para crear nuevos foros y exámenes. No puede rendir exámenes, en su lugar, el sistema le muestra las calificaciones de los estudiantes que ya rindieron. |
| **ESTUDIANTE** | student@codeacademy.com | student123 | *(Parte Privada)* Puede matricularse en cursos, marcar lecciones como completadas, comentar en foros, y rendir exámenes. Se le bloquea cualquier acceso de creación/edición de cursos o cuestionarios. |

*(La parte pública es accesible sin iniciar sesión e incluye el Home, el Catálogo de Cursos y el Detalle del Curso).*

---

## Cumplimiento de Requerimientos Obligatorios

### 1. Autenticación y Manejo de Sesión (JWT)
* **Login y Registro:** Implementados consumiendo los endpoints `/auth/login/` y `/auth/register/`.
* **Persistencia Segura:** El token JWT se almacena de forma persistente y cifrada utilizando `flutter_secure_storage` en la capa local.
* **Intercepción y 401:** Se utiliza Dio con el interceptor para adjuntar el token Bearer automáticamente en cada request. Si el token expira, el interceptor intenta refrescarlo, si falla, limpia la sesión y redirige al Login.
* **Rutas Protegidas:** Configurado mediante GoRouter. Si el usuario no tiene token, es redirigido fuera de las rutas privadas.

### 2. Control de Acceso por Roles (RBAC)
* El rol se lee directamente desde los claims del token JWT decodificado (`is_teacher`, `is_student`, `is_staff`).
* Las reglas de negocio determinan las vistas: El Administrador ve un botón hacia el Panel de Administración, el estudiante ve un atajo a Mis Foros/Pruebas y los botones de acción CRUD de foros se ocultan/muestran dependiendo si el usuario es Docente.

### 3. Consumo de API (Módulos CRUD)
Se consumen más de 2 módulos funcionales con operaciones completas:
1. **Módulo Cursos y Categorías:** *(Público)* Listado y Detalles; *(Admin)* Creación, Edición y Eliminación.
2. **Módulo Interactivo (Foros y Evaluaciones):** *(Docente)* Crea cuestionarios y foros; *(Estudiante)* Participa y envía respuestas.
3. **Módulo Usuarios:** *(Admin)* Listado y creación de nuevos usuarios mediante el backend.

### 4. Manejo de Estados y UX
* **Estados:** Manejados mediante `Provider` y `ChangeNotifier`.
* **UX:** Uso de overlay de carga, `CircularProgressIndicator`, validaciones Regex en formularios, y mensajes tipo `SnackBar` leyendo las excepciones unificadas.

---

## Estructura del Proyecto (Arquitectura Limpia)

El código fuente respeta la estructura recomendada dividida por capas:

* **core/:** Configuraciones globales, manejo de errores, formateadores, decodificador JWT y validadores.
* **data/:** Persistencia local segura (tokens) y llamadas remotas (DTOs, cliente Dio, interceptores y repositorios).
* **domain/:** Modelos de negocio lógicos e interfaces de repositorios.
* **presentation/:** Enrutamiento, manejadores de estado (Providers), pantallas (separadas por admin, auth, cart, catalog, orders y teacher) y widgets reutilizables.
* **theme/:** Colores, tipografías y configuración de tema centralizada.

---

## Evidencia Funcional

### Video Demostrativo Principal
**[Ver Video Principal](https://youtu.be/Kp0fPLNpl5c)**

En este video se demuestra:
- Navegación por la sección pública.
- Inicio de sesión con los diferentes roles.
- Consumo de la API REST.
- Operaciones CRUD.
- Control de acceso mediante JWT y RBAC.
- Funcionamiento general de la aplicación.

### Video Complementario
**[Ver Video Complementario](https://youtu.be/IH08hAuo9H0)**

Este video presenta un recorrido adicional por la aplicación y las principales funcionalidades implementadas.

---

## Capturas de Pantalla

<table align="center" style="border: none;">
  <tr>
    <td align="center" width="50%">
      <img src="https://github.com/user-attachments/assets/c7f1379b-30c5-4549-93d1-3fcd1778cec4" width="95%" style="border-radius: 10px; box-shadow: 2px 2px 10px rgba(0,0,0,0.1);"/>
    </td>
    <td align="center" width="50%">
      <img src="https://github.com/user-attachments/assets/381eddf7-b9c7-4eed-a341-5a04ca2d2b08" width="95%" style="border-radius: 10px; box-shadow: 2px 2px 10px rgba(0,0,0,0.1);"/>
    </td>
  </tr>
  <tr>
    <td align="center" width="50%">
      <img src="https://github.com/user-attachments/assets/9e8a3b9e-99ca-4be3-8755-175f6bb72640" width="95%" style="border-radius: 10px; box-shadow: 2px 2px 10px rgba(0,0,0,0.1);"/>
    </td>
    <td align="center" width="50%">
      <img src="https://github.com/user-attachments/assets/6284acb5-3cf1-42c8-bdea-021f0060b974" width="95%" style="border-radius: 10px; box-shadow: 2px 2px 10px rgba(0,0,0,0.1);"/>
    </td>
  </tr>
  <tr>
    <td align="center" colspan="2">
      <img src="https://github.com/user-attachments/assets/c8d345d6-5f2b-4279-8b71-b35c0f131d07" width="47.5%" style="border-radius: 10px; box-shadow: 2px 2px 10px rgba(0,0,0,0.1);"/>
    </td>
  </tr>
</table>

---

## Instalación y Ejecución

1. **Clonar el repositorio:**
   ```bash
   git clone <URL_DEL_REPOSITORIO>
