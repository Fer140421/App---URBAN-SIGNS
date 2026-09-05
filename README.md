# Urban Signs

Aplicación móvil para gestionar cotizaciones y pedidos de producción de **Urban Signs**, empresa dedicada a publicidad visual, letreros, rotulación, banners, stands y montaje.

## Datos del proyecto

Seguimiento de requisitos, estado comprobado y tareas pendientes: [Plan de entrega](docs/PLAN_DE_ENTREGA.md).

- **Proyecto:** Urban Signs
- **Versión:** 1.0.1+2
- **Módulo:** Desarrollo de Aplicaciones Móviles
- **Diplomado:** Desarrollo Web y Aplicaciones Móviles - UAJMS
- **Gestión:** 2026
- **Autor:** Daavid Fernando Camata Baspineiro
- **Repositorio:** [App - URBAN SIGNS](https://github.com/Fer140421/App---URBAN-SIGNS)

La versión del código es `1.0.1+2`, según `pubspec.yaml`.

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

El paquete Dart conserva el identificador interno `georescue_360`; el nombre de la aplicación es Urban Signs.

## Requisitos

- Flutter compatible con Dart `>=3.9.0 <4.0.0`.
- Android Studio o Visual Studio Code.
- Android SDK y un dispositivo o emulador.
- Android 7.0 o superior (API 24, según la configuración del proyecto).
- Git para descargar el repositorio y JDK 17 compatible con la configuración Android.
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

### Descargar y preparar el proyecto

Ejecutar en una terminal:

```bash
git clone https://github.com/Fer140421/App---URBAN-SIGNS.git urban-signs
cd urban-signs
flutter doctor
flutter pub get
flutter devices
```

Conectar un teléfono con depuración USB habilitada o iniciar un emulador Android. Si aparece más de un dispositivo, agregar `-d ID_DEL_DISPOSITIVO` al comando `flutter run`, usando el identificador mostrado por `flutter devices`.

### Modo DEMO

No requiere Supabase y conserva los datos solamente en memoria:

```bash
flutter run --dart-define-from-file=config/demo.json
```

### Modo LIVE con Supabase

1. Crear un proyecto en Supabase o utilizar uno ya preparado para Urban Signs.
2. Para un proyecto nuevo, ejecutar [supabase/01_schema_completo.sql](supabase/01_schema_completo.sql) en el SQL Editor antes de registrar usuarios. Crea las tablas `profiles`, `quotations`, `orders`, los triggers, las políticas RLS y el bucket de imágenes.
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

En Windows PowerShell, la copia de la plantilla se realiza con `Copy-Item config/live.example.json config/live.json`; en Linux/macOS, con `cp config/live.example.json config/live.json`. Hacerlo solo si todavía no existe la configuración local, para conservar sus valores.

En la pantalla de acceso, registrar una cuenta de prueba. Si Supabase solicita confirmación por correo, confirmar la cuenta antes de iniciar sesión. Las cuentas nuevas reciben el rol `user`; no se necesita rol administrador para gestionar registros propios.

En VS Code también se puede seleccionar **PF360 - SUPABASE** en Ejecutar y depurar. La configuración **PF360 - DEMO (sin Supabase)** utiliza datos temporales. Ejecutar `flutter run` sin parámetros inicia DEMO por defecto. Después de cambiar la configuración, detener y volver a ejecutar la aplicación.

### Cotización y pedido

La cotización es la propuesta de trabajo y precio para el cliente. Al aceptar la propuesta, abrir su detalle y seleccionar **Aprobar y crear pedido de producción**; indicar anticipo y fecha de entrega y confirmar. La aplicación copia los datos al pedido para continuar con producción y cobros.

También se puede registrar un pedido directamente cuando el trabajo ya está confirmado. El total de la cotización se calcula como cantidad por precio unitario; el área se calcula por separado. El saldo del pedido es el total menos el anticipo y los abonos acumulados.

## Comprobaciones

```bash
flutter pub get
flutter analyze
flutter test
```

Resultados registrados el 5 de septiembre de 2026: análisis sin incidencias y cuatro pruebas automatizadas aprobadas. El autor confirmó manualmente el funcionamiento general en LIVE. Las pruebas automatizadas cubren modelos y repositorios DEMO; no sustituyen la instalación y prueba del APK final.

## Generación del APK Release

Con Android SDK configurado, dispositivo de destino identificado y `config/live.json` preparado, ejecutar desde la raíz:

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

Crear la carpeta `APK` si no existe y copiar el archivo generado con el nombre indicado. Para instalar mediante Android SDK Platform Tools, con el teléfono conectado, ejecutar:

```bash
adb install -r APK/UrbanSigns_1.0.0_release.apk
```

También se puede transferir el APK al teléfono y abrirlo para instalarlo. Si Android informa una firma incompatible con una instalación previa, revisar la firma antes de reemplazarla; desinstalar la aplicación elimina sus datos locales.

La configuración Gradle usa la firma definida en `android/key.properties` cuando existe; de lo contrario utiliza la firma de depuración para el build Release. Conservar la misma firma para actualizaciones y no incluir claves ni propiedades de firma en la entrega.

Para la preparación de esta entrega se creó una firma local propia en `android/app/urban-signs-release.jks`, configurada mediante `android/key.properties`. Ambos archivos están excluidos de Git. El autor debe respaldarlos juntos en un lugar privado para poder generar futuras actualizaciones con la misma firma. Una copia nueva del repositorio necesita configurar su firma antes de distribuir un APK firmado con esa identidad.

## Flujo principal de verificación

1. Registrar un usuario e iniciar sesión.
2. Crear una cotización de prueba, consultarla y editarla.
3. Aprobar esa cotización y convertirla en pedido.
4. Editar el pedido, cambiar su estado y registrar un abono.
5. Adjuntar una imagen y comprobarla en Supabase Storage.
6. Probar GPS, mapa y WhatsApp.
7. Reiniciar la aplicación y confirmar la persistencia.
8. Probar eliminación con registros desechables separados del recorrido anterior.

## Limitaciones conocidas

- El modo DEMO pierde los cambios al reiniciar.
- El modo LIVE depende de Internet y de Supabase.
- WhatsApp requiere una aplicación o navegador compatible.
- GPS, cámara y galería requieren permisos del usuario.
- La conversión a pedido ejecuta dos operaciones consecutivas; ante un corte de conexión debe comprobarse el resultado.
- No incluye notificaciones push ni funcionamiento completo sin conexión.
- Las pruebas actuales cubren modelos y repositorios DEMO; faltan pruebas de integración LIVE.
- El servicio de clima está incluido en el código, pero las pantallas actuales no lo invocan ni muestran información meteorológica.
- Se mantienen pendientes de revisión específica las entradas numéricas inválidas y la recuperación ante fallos de red; consultar el plan de entrega.

## Seguridad

- Las tablas utilizan Row Level Security.
- Las operaciones requieren autenticación.
- Storage organiza archivos por usuario.
- Credenciales locales, keystores y propiedades de firma están excluidos mediante `.gitignore`.
- Las evidencias no deben mostrar información personal real.

## Documentación adicional

El [plan de entrega](docs/PLAN_DE_ENTREGA.md) registra el avance y los requisitos pendientes. Algunos manuales de `docs/` todavía describen el ejemplo original GeoRescue; para ejecutar Urban Signs, seguir este README hasta que esos manuales se actualicen. `evidencias/` está destinada a las capturas de la entrega final.
