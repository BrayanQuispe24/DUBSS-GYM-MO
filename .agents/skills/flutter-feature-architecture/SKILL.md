---
name: flutter-feature-architecture
description: Arquitectura Flutter por funcionalidades usando Dio, Riverpod y GoRouter; integración con backend existente.
---

# Skill: Arquitectura Flutter por funcionalidades

## Propósito

Aplicar y mantener una arquitectura **feature-first** con separación de responsabilidades para una aplicación Flutter cuyo **backend ya está implementado**. Las librerías principales son **Dio** (HTTP), **flutter_riverpod** (estado e inyección de dependencias) y **go_router** (navegación).

> Esta skill rige modificaciones y nuevas funcionalidades del frontend Flutter. No autoriza modificar, recrear ni asumir contratos del backend.

## Reglas obligatorias

1. **Inspeccionar antes de implementar.** Revisar `pubspec.yaml`, carpetas actuales, rutas, providers y cliente HTTP. Antes de integrar endpoints, consultar los contratos existentes (OpenAPI/Swagger, documentación o código del backend accesible). No inventar rutas, campos, estados, permisos ni estructuras JSON.
2. **Mantener la estructura acordada.** Ubicar cada funcionalidad en `lib/features/<feature>/`. Evitar archivos gigantes, lógica HTTP dentro de widgets y acceso directo a almacenamiento seguro desde pantallas.
3. **Mantener responsabilidades separadas.** `presentation` renderiza y coordina interacciones; `domain` modela reglas y contratos cuando sean necesarios; `data` implementa repositorios, modelos de transporte y fuentes remotas. No crear capas o casos de uso vacíos solo por cumplir un patrón.
4. **Riverpod es el mecanismo principal de estado.** No introducir Provider, Bloc, GetX u otro gestor sin solicitud expresa. Emplear `Provider` para dependencias, `FutureProvider` para lecturas sencillas, y `Notifier`/`AsyncNotifier` para estados con operaciones. Evitar estados globales mutables fuera de Riverpod.
5. **Dio es el único cliente HTTP de aplicación.** Centralizar `baseUrl`, tiempos de espera, encabezados e interceptores. Los repositorios consumen Dio a través del cliente compartido; las pantallas nunca llaman a Dio directamente.
6. **GoRouter administra la navegación.** Declarar rutas en `core/router/app_router.dart`; controlar redirecciones por autenticación y rol según reglas confirmadas del backend. No usar chequeos de rol solo del frontend como mecanismo de seguridad.
7. **Tokens con almacenamiento seguro.** Usar `flutter_secure_storage` para tokens y secretos de sesión; no guardar JWT en `shared_preferences`. No registrar tokens, contraseñas ni datos sensibles en logs.
8. **Respetar el backend existente.** Implementar solo el cliente de los endpoints disponibles y gestionar adecuadamente códigos HTTP, errores de red, expiración de sesión y paginación. No cambiar el backend salvo instrucción explícita del usuario.
9. **Código tipado y mantenible.** Preferir modelos tipados y conversiones JSON explícitas. `freezed`/`json_serializable` pueden incorporarse si están aprobados o ya instalados; no agregarlos sin necesidad.
10. **Evitar dependencias innecesarias.** Antes de instalar una librería, justificar su propósito y verificar compatibilidad con las versiones de Flutter/Dart del proyecto.
11. **Probar los cambios.** Correr, si el entorno lo permite, `flutter analyze` y pruebas relevantes; no afirmar que pasaron si no se ejecutaron. Incluir pruebas para repositorios y providers críticos con clientes HTTP simulados.
12. **No suponer la plataforma o URL.** Resolver el `baseUrl` por entorno y plataforma según configuración real del proyecto (emulador Android, iOS, web o dispositivo físico). No dejar endpoints locales fijos en código de producción.

## Estructura objetivo

```text
lib/
├── main.dart
├── app.dart
├── core/
│   ├── network/
│   │   ├── dio_client.dart
│   │   └── auth_interceptor.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── storage/
│   │   └── secure_storage.dart
│   └── errors/
│       └── app_exception.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── providers/
│   │       └── screens/
│   ├── pacientes/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── providers/
│   │       └── screens/
│   ├── citas/
│   └── reportes/
└── shared/
    └── widgets/
```

**Extensión coherente:** cuando un módulo crezca, puede adoptar las mismas subcarpetas de `auth` o `pacientes`. La ubicación específica de `data/datasources/`, `domain/entities/`, `domain/repositories/`, `domain/usecases/` o `presentation/widgets/` se añade **solo cuando exista una necesidad real**. No mover archivos que funcionan solo por homogeneidad estética.

## Responsabilidad de componentes

| Componente | Función |
| --- | --- |
| `main.dart` | Inicializar Flutter y montar `ProviderScope` antes de ejecutar la app. |
| `app.dart` | Configurar `MaterialApp.router`, tema y ajustes globales. |
| `core/network/dio_client.dart` | Crear/configurar la instancia compartida de Dio. |
| `core/network/auth_interceptor.dart` | Inyectar credenciales autorizadas y gestionar errores de sesión. |
| `core/router/app_router.dart` | Definir rutas y redirecciones de navegación. |
| `core/storage/secure_storage.dart` | Encapsular lectura, escritura y borrado de credenciales. |
| `core/errors/app_exception.dart` | Representar errores de aplicación legibles y tratables. |
| `features/*/data/` | Modelos API, fuentes de datos e implementaciones de repositorio. |
| `features/*/domain/` | Entidades, contratos y reglas de negocio si son necesarias. |
| `features/*/presentation/providers/` | Estado Riverpod y coordinación de las operaciones de UI. |
| `features/*/presentation/screens/` | Pantallas sin detalles de HTTP o persistencia. |
| `shared/widgets/` | Widgets genéricos reutilizables entre funcionalidades. |

## Dependencias

### Obligatorios para el stack acordado

- `dio`
- `flutter_riverpod`
- `go_router`
- `flutter_secure_storage` para autenticación persistente basada en tokens, cuando el flujo del backend lo requiera.

### Opcionales según necesidad

- `freezed_annotation`, `freezed`, `json_annotation`, `json_serializable`, `build_runner`: DTOs/modelos inmutables y serialización con generación de código.
- `shared_preferences`: preferencias no sensibles.
- `cached_network_image`: imágenes remotas con caché.
- `intl`: formatos e internacionalización.
- `drift`: almacenamiento relacional local/offline.
- `talker`: logs y diagnóstico sin datos sensibles.

Antes de instalar paquetes opcionales, comprobar si Flutter/Dart o dependencias existentes ya cubren el caso. No duplicar servicios de la misma responsabilidad.

## Flujo esperado de una consulta REST

```text
Screen (ConsumerWidget / ConsumerStatefulWidget)
  -> Provider Riverpod
  -> Repository (contrato opcional en domain; implementación en data)
  -> Dio client / AuthInterceptor
  -> API del backend existente
  -> DTO tipado / mapeo de errores
  -> AsyncValue (data/loading/error)
  -> Screen
```

Para escritura (POST/PUT/PATCH/DELETE), preferir un `AsyncNotifier` u otro controlador Riverpod coherente. Mostrar estados de proceso y errores; invalidar o actualizar los providers de lectura pertinentes tras éxito confirmado, evitando resultados obsoletos.

## Integración de API existente: procedimiento

1. Identificar endpoint real, método HTTP, autorización, parámetros, paginación, cuerpo, respuesta y códigos de error.
2. Crear o adaptar un DTO tipado al **contrato real**; distinguir modelos de API de entidades del dominio si hay una razón funcional.
3. Añadir el método al repositorio del módulo; usar cliente Dio inyectado, nunca uno nuevo por pantalla.
4. Mapear `DioException`, respuestas de negocio y errores de parsing a excepciones de aplicación sin ocultar errores inesperados.
5. Exponer datos/operaciones mediante Riverpod y consumirlos desde `presentation`.
6. Aplicar reglas de sesión y navegación mediante componentes centrales.
7. Cubrir loading, vacío, error, reintento y éxito en la interfaz.
8. Agregar pruebas y verificar análisis estático si el entorno permite ejecutarlos.

## Seguridad y autenticación

- El backend es la fuente de verdad para identidad, roles y permisos.
- Los interceptores deben enviar `Authorization: Bearer <token>` **solo si el endpoint requiere o admite ese token**, según contrato.
- Manejar `401` y `403` por separado; no asumir que ambos significan sesión vencida.
- Si el backend cuenta con endpoint de refresh, implementar renovación evitando solicitudes concurrentes redundantes y bucles de reintento; si no existe, no inventarlo.
- Al cerrar sesión, limpiar credenciales y estados sensibles; asegurar que los providers de otro usuario no conserven datos de la sesión anterior.
- Evitar que errores o telemetría muestren credenciales o información clínica sensible.
- No confiar en filtros de navegación para impedir operaciones no autorizadas: el servidor debe validarlas.

## Convenciones de diseño

- Archivos y carpetas en `snake_case`; clases en `PascalCase`; miembros en `camelCase`.
- Preferir composición, inyección de dependencias y objetos inmutables.
- Evitar lógica empresarial en `build()` y widgets demasiado grandes.
- `ref.watch` para dependencias reactivas; `ref.read` para acciones puntuales; `ref.listen` para efectos adecuados de UI.
- Usar `select` cuando ayude a reducir reconstrucciones; no optimizar sin evidencia.
- No transformar todos los datos de una respuesta en `dynamic` cuando puede tiparse con DTO.
- No utilizar `print` para datos sensibles; los logs deben poder deshabilitarse en producción.

## Criterios de aceptación de cada funcionalidad

- [ ] Sigue la estructura feature-first definida.
- [ ] Usa un contrato API existente y verificado; no hay endpoints inventados.
- [ ] La pantalla no hace llamadas HTTP ni lee JWT directamente.
- [ ] El estado se gestiona con Riverpod y contempla loading/data/error.
- [ ] La navegación pasa por GoRouter y respeta sesión/roles conocidos.
- [ ] DTOs y errores tienen tipos adecuados.
- [ ] No expone credenciales ni información sensible en logs.
- [ ] Se revisaron pruebas y `flutter analyze`, informando si no fue posible ejecutarlos.

## Formato de respuesta de un agente al implementar

1. **Inspección:** archivos existentes y contratos de backend consultados.
2. **Plan breve:** módulos y archivos a crear/modificar.
3. **Implementación:** cambios ajustados a la estructura acordada, sin rehacer el backend.
4. **Validación:** pruebas/análisis ejecutados y resultados reales.
5. **Pendientes:** dudas de contrato, permisos o configuración que impidan integración correcta.

## Antipatrones prohibidos

- URLs/endpoints de ejemplo presentados como reales.
- Instancias de Dio dispersas en pantallas.
- `BuildContext` usado como dependencia de lógica de datos.
- JWT en preferencias simples o hardcodeado.
- Acceso de cualquier módulo a implementaciones internas de `data/` de otro sin contrato justificado.
- `setState` para duplicar estado compartido ya administrado por Riverpod.
- Añadir paquetes, estructuras o funcionalidades sin un requerimiento comprobable.
- Reescribir o cambiar el backend ya implementado sin autorización expresa.
