# CodeAcademy - Aplicacion Movil en Flutter (Consumo de API Django)

Este proyecto es una aplicacion movil desarrollada en Flutter utilizando Arquitectura Limpia (Clean Architecture). La aplicacion cumple con todos los requisitos del proyecto final, consumiendo una API REST desarrollada en Django, con secciones publicas y privadas protegidas por autenticacion JWT y control de acceso basado en roles (RBAC).

## Repositorios y Documentacion de la API

* **Repositorio del Backend:** [CodeAcademy Backend Repository](https://github.com/sergio001g/CodeAcademy_bakend)
* **API REST Base (Produccion):** [CodeAcademy API](https://codeacademy-api.uaeftt-ute.site/api/)
* **Documentacion Swagger (Endpoints):** [Swagger Docs](https://codeacademy-api.uaeftt-ute.site/api/docs/)
* **Django Admin Panel:** [Django Admin](https://codeacademy-api.uaeftt-ute.site/admin/)

---

## Requisitos del Sistema y Configuracion (URL de API)

La aplicacion consume directamente el backend de produccion. La configuracion de la URL base se encuentra centralizada en el archivo [app_config.dart](file:///c:/Users/User/Downloads/code/code/lib/core/config/app_config.dart).

Para cambiar la URL base, simplemente modifique la constante del archivo de configuracion correspondiente.

---

## Credenciales de Prueba (Garantizadas en Produccion)

Para validar el control de acceso por roles, se han configurado cuentas de prueba reales en la API:

| Rol de Usuario | Correo Electronico (Email) | Contrasena | Permisos y Reglas de Negocio (RBAC) |
|---|---|---|---|
| **ADMINISTRADOR** | admin@codeacademy.com | admin123 | (Parte Privada Admin) Puede crear, editar y eliminar usuarios, cursos y categorias. Tiene un Panel de Administracion visible exclusivo para su rol. |
| **DOCENTE** | teacher@codeacademy.com | teacher123 | (Parte Privada) Solo puede ver sus propios cursos. Tiene permisos exclusivos para crear nuevos foros y examenes. No puede rendir examenes, en su lugar, el sistema le muestra las calificaciones de los estudiantes que ya rindieron. |
| **ESTUDIANTE** | student@codeacademy.com | student123 | (Parte Privada) Puede matricularse en cursos, marcar lecciones como completadas, comentar en foros, y rendir examenes. Se le bloquea cualquier acceso de creacion/edicion de cursos o cuestionarios. |

(La parte publica es accesible sin iniciar sesion e incluye el Home, el Catalogo de Cursos y el Detalle del Curso).

---

## Cumplimiento de Requerimientos Obligatorios

### 1. Autenticacion y Manejo de Sesion (JWT)
* **Login y Registro:** Implementados consumiendo los endpoints `/auth/login/` y `/auth/register/`.
* **Persistencia Segura:** El token JWT se almacena de forma persistente y cifrada utilizando `flutter_secure_storage` en la capa local en el archivo [secure_storage.dart](file:///c:/Users/User/Downloads/code/code/lib/data/local/secure_storage.dart).
* **Intercepcion y 401:** Se utiliza `Dio` con el interceptor [auth_interceptor.dart](file:///c:/Users/User/Downloads/code/code/lib/data/remote/interceptor/auth_interceptor.dart) para adjuntar el token `Bearer` automaticamente en cada request. Si el token expira (Error 401), el interceptor intenta refrescarlo (`/auth/token/refresh/`), si falla, limpia la sesion y redirige al Login.
* **Rutas Protegidas:** Configurado en [app_router.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/navigation/app_router.dart) mediante `GoRouter`. Si el usuario no tiene token, es redirigido fuera de las rutas privadas.

### 2. Control de Acceso por Roles (RBAC)
* El rol se lee directamente desde los claims del token JWT decodificado en [jwt_decoder.dart](file:///c:/Users/User/Downloads/code/code/lib/core/utils/jwt_decoder.dart) (`is_teacher`, `is_student`, `is_staff`).
* Las reglas de negocio determinan las vistas: El Administrador ve un boton hacia el Panel de Administracion, el estudiante ve un atajo a Mis Foros/Pruebas y los botones de accion CRUD de foros se ocultan/muestran dependiendo si el usuario es Docente.

### 3. Consumo de API (Modulos CRUD)
Se consumen mas de 2 modulos funcionales con operaciones completas:
1. **Modulo Cursos y Categorias:**
   * *Publico:* Listado y Detalles de curso.
   * *Admin:* Creacion, Edicion y Eliminacion desde el Panel Privado.
2. **Modulo Interactivo (Foros y Evaluaciones):**
   * *Docente:* Crea cuestionarios y foros.
   * *Estudiante:* Detalle/Listado de Foros, envio de respuestas a examenes.
3. **Modulo Usuarios (Admin):** Listado y creacion de nuevos usuarios mediante el backend.

### 4. Manejo de Estados y UX
* **Estados:** Manejados mediante `Provider` y `ChangeNotifier`.
* **UX:** Uso de [loading_overlay.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/widgets/loading_overlay.dart) y `CircularProgressIndicator` para peticiones en red. Validaciones de regex en formularios. Mensajes de exito y error mediante `ScaffoldMessenger` (SnackBar) leyendo las excepciones de [api_exception.dart](file:///c:/Users/User/Downloads/code/code/lib/core/error/api_exception.dart).

---

## Estructura del Proyecto (Arquitectura Limpia)

El codigo fuente respeta la estructura recomendada `data`, `domain`, `presentation`, `core` y `theme`:

* [lib/main.dart](file:///c:/Users/User/Downloads/code/code/lib/main.dart): Archivo principal de inicializacion.
* **core/**
  * [app_config.dart](file:///c:/Users/User/Downloads/code/code/lib/core/config/app_config.dart): Configuracion de variables globales.
  * [api_exception.dart](file:///c:/Users/User/Downloads/code/code/lib/core/error/api_exception.dart): Manejo unificado de excepciones de red.
  * [formatters.dart](file:///c:/Users/User/Downloads/code/code/lib/core/utils/formatters.dart): Utilitarios de formato de datos.
  * [jwt_decoder.dart](file:///c:/Users/User/Downloads/code/code/lib/core/utils/jwt_decoder.dart): Decodificador del token JWT para roles.
  * [validators.dart](file:///c:/Users/User/Downloads/code/code/lib/core/utils/validators.dart): Validaciones basicas para campos de texto.
* **data/**
  * [secure_storage.dart](file:///c:/Users/User/Downloads/code/code/lib/data/local/secure_storage.dart): Persistencia local segura de credenciales.
  * **remote/**
    * [dio_client.dart](file:///c:/Users/User/Downloads/code/code/lib/data/remote/api/dio_client.dart): Instanciador y configurador de Dio.
    * [auth_dto.dart](file:///c:/Users/User/Downloads/code/code/lib/data/remote/dto/auth_dto.dart): Objeto de transferencia de autenticacion.
    * [category_dto.dart](file:///c:/Users/User/Downloads/code/code/lib/data/remote/dto/category_dto.dart): Objeto de transferencia de categorias.
    * [course_dto.dart](file:///c:/Users/User/Downloads/code/code/lib/data/remote/dto/course_dto.dart): Objeto de transferencia de cursos.
    * [order_dto.dart](file:///c:/Users/User/Downloads/code/code/lib/data/remote/dto/order_dto.dart): Objeto de transferencia de ordenes.
    * [product_dto.dart](file:///c:/Users/User/Downloads/code/code/lib/data/remote/dto/product_dto.dart): Objeto de transferencia de productos.
    * [auth_interceptor.dart](file:///c:/Users/User/Downloads/code/code/lib/data/remote/interceptor/auth_interceptor.dart): Inyeccion de tokens JWT en llamadas.
  * **repository/**
    * [admin_repository_impl.dart](file:///c:/Users/User/Downloads/code/code/lib/data/repository/admin_repository_impl.dart): Implementacion de repositorio de administracion.
    * [auth_repository_impl.dart](file:///c:/Users/User/Downloads/code/code/lib/data/repository/auth_repository_impl.dart): Implementacion de repositorio de autenticacion.
    * [catalog_repository_impl.dart](file:///c:/Users/User/Downloads/code/code/lib/data/repository/catalog_repository_impl.dart): Implementacion de repositorio de catalogo.
    * [order_repository_impl.dart](file:///c:/Users/User/Downloads/code/code/lib/data/repository/order_repository_impl.dart): Implementacion de repositorio de ordenes.
* **domain/**
  * **model/**
    * [auth_models.dart](file:///c:/Users/User/Downloads/code/code/lib/domain/model/auth_models.dart): Modelos logicos de autenticacion.
    * [category.dart](file:///c:/Users/User/Downloads/code/code/lib/domain/model/category.dart): Modelo logico de categorias.
    * [certificate.dart](file:///c:/Users/User/Downloads/code/code/lib/domain/model/certificate.dart): Modelo logico de certificados.
    * [course.dart](file:///c:/Users/User/Downloads/code/code/lib/domain/model/course.dart): Modelo logico de cursos.
    * [forum.dart](file:///c:/Users/User/Downloads/code/code/lib/domain/model/forum.dart): Modelo logico de foros.
    * [order.dart](file:///c:/Users/User/Downloads/code/code/lib/domain/model/order.dart): Modelo logico de ordenes y matriculas.
    * [product.dart](file:///c:/Users/User/Downloads/code/code/lib/domain/model/product.dart): Modelo logico de productos.
    * [progress.dart](file:///c:/Users/User/Downloads/code/code/lib/domain/model/progress.dart): Modelo logico de progreso estudiantil.
    * [quiz.dart](file:///c:/Users/User/Downloads/code/code/lib/domain/model/quiz.dart): Modelo logico de cuestionarios y evaluaciones.
    * [review.dart](file:///c:/Users/User/Downloads/code/code/lib/domain/model/review.dart): Modelo logico de reseñas y comentarios.
    * [subcategory.dart](file:///c:/Users/User/Downloads/code/code/lib/domain/model/subcategory.dart): Modelo logico de subcategorias.
    * [user.dart](file:///c:/Users/User/Downloads/code/code/lib/domain/model/user.dart): Modelo logico de usuarios.
    * [wishlist.dart](file:///c:/Users/User/Downloads/code/code/lib/domain/model/wishlist.dart): Modelo logico de favoritos.
  * **repository/**
    * [admin_repository.dart](file:///c:/Users/User/Downloads/code/code/lib/domain/repository/admin_repository.dart): Interfaz de administracion.
    * [auth_repository.dart](file:///c:/Users/User/Downloads/code/code/lib/domain/repository/auth_repository.dart): Interfaz de autenticacion.
    * [catalog_repository.dart](file:///c:/Users/User/Downloads/code/code/lib/domain/repository/catalog_repository.dart): Interfaz de catalogo.
    * [order_repository.dart](file:///c:/Users/User/Downloads/code/code/lib/domain/repository/order_repository.dart): Interfaz de ordenes.
* **presentation/**
  * [app_router.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/navigation/app_router.dart): Enrutamiento general con guards de seguridad.
  * **providers/**
    * [admin_provider.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/providers/admin_provider.dart): Proveedor de estado administrativo.
    * [auth_provider.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/providers/auth_provider.dart): Proveedor de estado de sesion.
    * [cart_provider.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/providers/cart_provider.dart): Proveedor de carrito de compras.
    * [catalog_provider.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/providers/catalog_provider.dart): Proveedor de catalogo de cursos.
    * [order_provider.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/providers/order_provider.dart): Proveedor de ordenes.
    * [teacher_provider.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/providers/teacher_provider.dart): Proveedor de la consola de docentes.
  * **screens/**
    * **admin/**
      * [admin_categories_screen.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/screens/admin/admin_categories_screen.dart): Listado CRUD de categorias.
      * [admin_courses_screen.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/screens/admin/admin_courses_screen.dart): Listado CRUD de cursos.
      * [admin_orders_screen.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/screens/admin/admin_orders_screen.dart): Panel administrativo de ordenes.
      * [admin_products_screen.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/screens/admin/admin_products_screen.dart): Panel administrativo de productos.
      * [admin_users_screen.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/screens/admin/admin_users_screen.dart): Panel administrativo de gestion de usuarios.
      * [category_form_screen.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/screens/admin/category_form_screen.dart): Formulario de creacion y edicion de categorias.
      * [course_form_screen.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/screens/admin/course_form_screen.dart): Formulario de creacion y edicion de cursos.
    * **auth/**
      * [login_screen.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/screens/auth/login_screen.dart): Interfaz de Login de usuario.
      * [profile_screen.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/screens/auth/profile_screen.dart): Dashboard privado del perfil.
      * [register_screen.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/screens/auth/register_screen.dart): Interfaz de Registro de usuario.
    * **cart/**
      * [cart_screen.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/screens/cart/cart_screen.dart): Interfaz de carrito de compras.
    * **catalog/**
      * [catalog_screen.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/screens/catalog/catalog_screen.dart): Home y catalogo de cursos.
      * [course_detail_screen.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/screens/catalog/course_detail_screen.dart): Ficha informativa del curso.
      * [forum_screen.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/screens/catalog/forum_screen.dart): Pantalla interactiva del foro de discusion.
      * [lesson_screen.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/screens/catalog/lesson_screen.dart): Reproductor de lecciones.
      * [product_detail_screen.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/screens/catalog/product_detail_screen.dart): Detalle de productos.
      * [quiz_screen.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/screens/catalog/quiz_screen.dart): Pantalla de evaluacion interactiva.
      * [wishlist_screen.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/screens/catalog/wishlist_screen.dart): Listado de favoritos.
    * **orders/**
      * [certificate_screen.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/screens/orders/certificate_screen.dart): Visor de certificados aprobados.
      * [order_detail_screen.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/screens/orders/order_detail_screen.dart): Ficha de detalle de compra.
      * [orders_screen.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/screens/orders/orders_screen.dart): Historial de compras.
    * **teacher/**
      * [lesson_form_screen.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/screens/teacher/lesson_form_screen.dart): Formulario de creacion de lecciones para docentes.
      * [teacher_course_form_screen.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/screens/teacher/teacher_course_form_screen.dart): Formulario de creacion de cursos para docentes.
      * [teacher_courses_screen.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/screens/teacher/teacher_courses_screen.dart): Listado de cursos del docente.
      * [teacher_lessons_screen.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/screens/teacher/teacher_lessons_screen.dart): Listado de lecciones del curso.
  * **widgets/**
    * [category_chip.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/widgets/category_chip.dart): Filtro por categoria.
    * [course_card.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/widgets/course_card.dart): Tarjeta de presentacion del curso.
    * [loading_overlay.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/widgets/loading_overlay.dart): Overlay modal de cargando.
    * [order_status_badge.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/widgets/order_status_badge.dart): Insignia de estado de pago.
    * [product_card.dart](file:///c:/Users/User/Downloads/code/code/lib/presentation/widgets/product_card.dart): Tarjeta de presentacion de productos.
* **theme/**
  * [app_colors.dart](file:///c:/Users/User/Downloads/code/code/lib/theme/app_colors.dart): Paleta de colores visuales.
  * [app_text_styles.dart](file:///c:/Users/User/Downloads/code/code/lib/theme/app_text_styles.dart): Tipografias y tamanos de letra.
  * [app_theme.dart](file:///c:/Users/User/Downloads/code/code/lib/theme/app_theme.dart): Configuracion central de ThemeData.
* **test/**
  * [widget_test.dart](file:///c:/Users/User/Downloads/code/code/test/widget_test.dart): Archivo de configuracion del set de pruebas.

---

## Evidencia Funcional (Capturas y Video)

(Por favor, inserte las URLs correspondientes a sus capturas de pantalla y al video final de demostracion en los siguientes campos).

**Enlace al Video Demostrativo (3 - 5 min):**
[Insertar link de YouTube, Drive o Teams aqui]

En el video demostrativo se detalla:
1. Navegacion libre en la Seccion Publica (Home y Catalogo de cursos).
2. Inicio de sesion exitoso como Estudiante, navegacion en la parte privada y prueba de examenes.
3. Inicio de sesion exitoso como Docente, administracion de cursos y visualizacion de calificaciones de alumnos.
4. Inicio de sesion exitoso como Administrador, acceso total al Panel Privado de Administracion y realizacion de operaciones CRUD de cursos y usuarios.

### Capturas de Pantalla Obligatorias

1. **Pantalla Publica Principal:**
   [Inserte la ruta de la captura local o enlace CDN de la pantalla publica aqui]
2. **Pantalla de Login:**
   [Inserte la ruta de la captura local o enlace CDN de la pantalla de login aqui]
3. **Pantalla Principal Privada (Dashboard/Menu):**
   [Inserte la ruta de la captura local o enlace CDN de la pantalla principal privada aqui]
4. **Listado Consumiendo API:**
   [Inserte la ruta de la captura local o enlace CDN del listado consumiendo la API de usuarios o cursos aqui]
5. **Formulario Creando o Editando (Exito):**
   [Inserte la ruta de la captura local o enlace CDN del formulario completado exitosamente aqui]
6. **Ejemplo de Restriccion por Rol (Accion Bloqueada/Oculta):**
   [Inserte la ruta de la captura local o enlace CDN de la accion bloqueada o deshabilitada para el rol de Estudiante aqui]

---

## Instalacion y Ejecucion Local

1. Instale el SDK de Flutter (version `>= 3.0.0` y `< 4.0.0` compatible con Dart).
2. Clone este repositorio en su maquina local.
3. Abra una terminal en el directorio raiz del proyecto y ejecute los siguientes comandos:
```bash
flutter pub get
flutter run
```
4. Se recomienda compilar y ejecutar las pruebas utilizando un emulador de dispositivo movil (Android o iOS) o su propio dispositivo fisico configurado en modo de depuracion USB.
