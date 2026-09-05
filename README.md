# Urban Signs

Aplicación móvil para gestionar cotizaciones y pedidos de producción de **Urban Signs**, empresa dedicada a publicidad visual, letreros, rotulación, banners, stands y montaje.

## Datos del proyecto

Seguimiento de requisitos, estado comprobado y tareas pendientes: [Plan de entrega](docs/PLAN_DE_ENTREGA.md).

- **Proyecto:** Urban Signs
- **Versión:** 1.0.0+1
- **Módulo:** Desarrollo de Aplicaciones Móviles
- **Diplomado:** Desarrollo Web y Aplicaciones Móviles - UAJMS
- **Gestión:** 2026
- **Autor:** Daavid Fernando Camata Baspineiro

## Problema y objetivo

Urban Signs necesita centralizar la información de sus clientes, cotizaciones y trabajos de producción. El manejo manual puede ocasionar pérdida de datos, cálculos inconsistentes y dificultades para conocer el estado o saldo de un pedido.

La aplicación permite registrar cotizaciones, convertirlas en pedidos, controlar anticipos y estados de producción y conservar la información en Supabase. También incorpora imágenes, ubicación de instalación, mapa y comunicación mediante WhatsApp.

## Funcionalidades implementadas

- Registro e inicio de sesión con Supabase Auth.
- Perfiles de usuario y roles `user` y `admin`.
- CRUD de cotizaciones y pedidos de producción.
- Cálculo de área, cantidad, precio unitario y total.
- Conversión de cotización aprobada en pedido.
- Control de estados, anticipos, abonos y saldo pendiente.
- Carga de imágenes en Supabase Storage.
- Ubicación GPS y mapa con OpenStreetMap.
- Información meteorológica.
- Comunicación mediante WhatsApp.
- Modos DEMO y LIVE.
- Tema oscuro y tarjetas compactas.

## Tecnologías utilizadas

- Flutter, Dart y Material 3.
- Provider y GoRouter.
- Supabase Auth, PostgreSQL, Row Level Security y Storage.
- Geolocator, Flutter Map y OpenStreetMap.
- Image Picker, HTTP y URL Launcher.
- Shared Preferences.

## Requisitos

- Flutter compatible con Dart `>=3.9.0 <4.0.0`.
- Android Studio o Visual Studio Code.
- Android SDK y un dispositivo o emulador.
- Conexión a Internet y proyecto Supabase para el modo LIVE.

```bash
flutter doctor
flutter --version
flutter pub get
```

## Estructura general

```text
lib/
|-- controllers/   # Estado y lógica
|-- core/          # Configuración, rutas, tema y constantes
|-- models/        # Modelos de datos
|-- repositories/  # Persistencia DEMO y Supabase
|-- screens/       # Pantallas
|-- services/      # Cámara, ubicación, clima y preferencias
`-- widgets/       # Componentes reutilizables

supabase/           # Esquema SQL
test/               # Pruebas automatizadas
docs/               # Documentación complementaria
scripts/            # Comandos auxiliares
config/              # Configuración y plantilla LIVE
```

## Instalación y ejecución

### Modo DEMO

No requiere Supabase y conserva los datos solamente en memoria:

```bash
flutter run --dart-define-from-file=config/demo.json
```

### Modo LIVE con Supabase

1. Crear un proyecto en Supabase.
2. Ejecutar `supabase/01_schema_completo.sql` en el SQL Editor.
3. Copiar `config/live.example.json` como `config/live.json`.
4. Completar la URL y la publishable/anon key pública.

```json
{
  "DEMO_MODE": "false",
  "SUPABASE_URL": "https://TU-PROYECTO.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "TU-PUBLISHABLE-KEY"
}
```

```bash
flutter run --dart-define-from-file=config/live.json
```

`config/live.json` está excluido del repositorio. Nunca se debe incluir una secret/service-role key, contraseña o token privado.

## Comprobaciones

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
```

## Generación del APK Release

```bash
flutter build apk --release --dart-define-from-file=config/live.json
```

El resultado se genera en:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Para la entrega debe copiarse como:

```text
APK/UrbanSigns_1.0.0_release.apk
```

Debe instalarse y probarse desde el icono del dispositivo, sin depender de `flutter run`.

## Flujo principal de verificación

1. Registrar un usuario e iniciar sesión.
2. Crear, consultar, editar y eliminar una cotización.
3. Aprobar una cotización y convertirla en pedido.
4. Editar el pedido, cambiar su estado y registrar un abono.
5. Adjuntar una imagen y comprobarla en Supabase Storage.
6. Probar GPS, mapa y WhatsApp.
7. Reiniciar la aplicación y confirmar la persistencia.

## Limitaciones conocidas

- El modo DEMO pierde los cambios al reiniciar.
- El modo LIVE depende de Internet y de Supabase.
- WhatsApp requiere una aplicación o navegador compatible.
- GPS, cámara y galería requieren permisos del usuario.
- La conversión a pedido ejecuta dos operaciones consecutivas; ante un corte de conexión debe comprobarse el resultado.
- No incluye notificaciones push ni funcionamiento completo sin conexión.
- Las pruebas actuales cubren modelos y repositorios DEMO; faltan pruebas de integración LIVE.

## Seguridad

- Las tablas utilizan Row Level Security.
- Las operaciones requieren autenticación.
- Storage organiza archivos por usuario.
- Credenciales locales, keystores y propiedades de firma están excluidos mediante `.gitignore`.
- Las evidencias no deben mostrar información personal real.

## Documentación adicional

`docs/` contiene manuales de instalación, uso, arquitectura, pruebas y generación Android. `evidencias/` está destinada a las capturas de la entrega final.
