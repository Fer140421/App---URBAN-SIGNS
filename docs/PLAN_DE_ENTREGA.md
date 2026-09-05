# Urban Signs: diagnóstico y plan de entrega

Fecha de revisión: 5 de septiembre de 2026.

Fuente: `C:/Users/fcama/Downloads/Lineamientos_Proyecto_Final_Modulo3 (1).pdf`, secciones 1 a 11. Este documento registra el avance comprobado y las tareas necesarias para la entrega. No reconstruye una planificación anterior.

## Punto actual

El usuario confirmó que funcionan todos los CRUD de cotizaciones y pedidos en su sesión LIVE (previamente indicó que Ajustes muestra conexión a Supabase). Se registra como validación manual reportada por el usuario: crear, consultar, actualizar y eliminar. El análisis estático pasa y las cuatro pruebas actuales pasan. Faltan confirmar por separado conversión, abonos, persistencia tras reiniciar, casos de error e integraciones. La entrega todavía no está completa: faltan APK Release, comprobación final en Android, evidencias y un historial progresivo; parte de la documentación sigue describiendo GeoRescue. El dispositivo utilizado en esta prueba no fue especificado.

Estados: **Cumple** = existe evidencia suficiente para el aspecto indicado; **Parcial** = hay implementación o documentación, pero faltan partes; **Pendiente** = falta el entregable; **Por verificar** = no se probó y no se puede afirmar que funcione o falle.

## Matriz frente a los lineamientos

| Requisito | Estado | Evidencia actual | Qué falta para cerrarlo |
|---|---|---|---|
| Aplicación Flutter/Dart con estructura organizada (1 y 2) | Cumple en código | `pubspec.yaml`; carpetas `lib/models`, `controllers`, `repositories`, `screens`, `services`; análisis sin incidencias | La ejecución funcional se verifica por separado. |
| Apertura y flujo principal estable (2.1) | Parcial: CRUD confirmado por el usuario | El usuario abrió la app y confirmó todos los CRUD de cotizaciones y pedidos en su sesión LIVE | Confirmar explícitamente conversión y abonos; registrar dispositivo y evidencias del recorrido completo en Android. |
| Navegación e interfaz coherentes (2.2) | Parcial | GoRouter en `lib/core/router/app_router.dart` y pantallas de Urban Signs | Probar navegación, regreso, teclado, textos, tamaños de pantalla y estados vacíos. |
| Gestión de estado (alcance de 2) | Cumple en código | Provider y controladores conectados en `lib/main.dart` | Verificar actualización visual dentro del recorrido funcional. |
| Manejo de información, servicios y persistencia (2.3) | Parcial: CRUD LIVE confirmado por el usuario | CRUD de cotizaciones y pedidos reportado como funcional; repositorios Supabase, esquema SQL y configuración LIVE presentes | Comprobar persistencia tras reiniciar, autenticación en sus distintos casos y comportamiento sin conexión. No se inspeccionaron directamente las filas de Supabase. DEMO guarda operaciones en memoria. |
| Capacidades móviles (alcance de 2) | Parcial | Servicios GPS e imágenes, mapa y enlace WhatsApp | Probar permisos aceptados/denegados, cámara/galería, carga de imagen, mapa y apertura de WhatsApp en Android. |
| Validaciones y errores previsibles (2.4) | Parcial | Formularios con algunas validaciones y bloques de manejo de errores | Completar validaciones numéricas y probar errores de red, permisos y conversión. Ver hallazgos. |
| Nombre, propósito y contenido propios (2.5) | Parcial | README y pantallas identifican Urban Signs y el problema de cotizaciones/pedidos | Actualizar manuales heredados y descripción del paquete. El identificador técnico `georescue_360` no es por sí solo un incumplimiento. |
| Repositorio con código e historial progresivo (3) | Parcial | Git local y remoto; único commit local `5c27a34 app v1`; cambios de trabajo sin commit | Registrar las próximas etapas reales con commits descriptivos y publicarlas. No inventar ni retrofechar avances. |
| README con los 11 contenidos mínimos (4) | Cumple en contenido | `README.md` incluye nombre, objetivo, funciones, tecnologías, requisitos, instalación, estructura, build, versión, limitaciones y autor | Validar instrucciones desde una copia limpia y actualizarlo con el resultado final. Hay cambios locales todavía sin publicar. |
| APK Release generado (5) | Pendiente | No se encontró ningún `.apk` bajo `build/` ni carpeta `APK/` en la raíz | Generar Release, conservar registro exitoso y copiar como `APK/UrbanSigns_1.0.0_release.apk`. |
| APK instalado, abierto desde su icono y probado (5) | Por verificar | No hay evidencia de instalación disponible | Instalar el APK final y recorrer el flujo sin depender de `flutter run`. |
| Capturas obligatorias del proceso (6) | Pendiente | `evidencias/` contiene únicamente `README.md` con sugerencias del ejemplo | Crear las 11 evidencias indicadas abajo, legibles y con datos de prueba. |
| Organización e identificación de entrega (7 y 8) | Parcial | README y carpeta de evidencias presentes | Preparar carpeta final, APK, capturas y `REPOSITORIO.txt`; ZIP si la plataforma admite un solo archivo. |
| Enlace Git con acceso para revisión (7 y 8) | Parcial | `git ls-remote origin HEAD` respondió con `5c27a34ad9b2a7194d5828999268cf549f6a1843` | Confirmar acceso del docente; la consulta desde este entorno no prueba acceso sin credenciales. Crear `REPOSITORIO.txt`. |
| Ausencia de secretos y datos personales en entrega (3 y 9) | Parcial | `.gitignore` excluye configuración LIVE, keystores, `key.properties` y `.env`; no se encontraron esos archivos sensibles entre los nombres versionados consultados | Revisar contenidos e historial completo y el paquete final. Ignorar archivos no acredita ausencia de secretos. Revisar capturas y datos de prueba. |
| Entrega verificable por otra persona (10 y 11) | Pendiente | La base técnica y el README permiten preparar la revisión | Cerrar APK, instalación, evidencias, acceso y ensayo de entrega independiente. |

No se asigna un porcentaje: contar código implementado como si fuera una función probada produciría una cifra engañosa.

## Comprobaciones realizadas

| Comprobación | Resultado de esta revisión | Alcance |
|---|---|---|
| `flutter analyze --no-pub` | Sin incidencias; salida 0 | Análisis estático, no ejecución en dispositivo. |
| `flutter test --no-pub` | 4 pruebas aprobadas; salida 0 | Modelos de cotización/pedido y operaciones de repositorios DEMO. |
| `git log --oneline` | Un commit: `5c27a34 app v1` | Historial local disponible. |
| `git ls-remote origin HEAD` | Remoto accesible desde este entorno | No confirma permisos del evaluador. |
| Búsqueda de APK y evidencias | Sin APK bajo `build/`; `evidencias/` solo contiene su README | No se buscaron entregables fuera de este proyecto. |

Las pruebas automatizadas actuales no cubren interfaz, controladores de conversión/abonos, Supabase LIVE, RLS, permisos ni instalación. La confirmación manual del usuario sobre los CRUD LIVE se registra por separado abajo. Los comandos se ejecutaron con las dependencias locales existentes, sin volver a resolverlas. El primer intento restringido de análisis no produjo resultado y se interrumpió; el análisis posterior terminó correctamente fuera de ese entorno.

### Validación manual confirmada por el usuario (2026-09-05)

Fuente: mensaje «si funciona todo los CRUD», en el contexto de su sesión configurada en Supabase. Dispositivo no especificado; capturas de éxito pendientes.

- [x] Crear cotizaciones.
- [x] Consultar/listar cotizaciones.
- [x] Actualizar cotizaciones.
- [x] Eliminar cotizaciones.
- [x] Crear pedidos.
- [x] Consultar/listar pedidos.
- [x] Actualizar pedidos.
- [x] Eliminar pedidos.
- [ ] Confirmar explícitamente aprobación y conversión de cotización a pedido después de la corrección de fechas.
- [ ] Confirmar registro de abonos y cálculo del saldo.
- [ ] Confirmar persistencia al cerrar y volver a abrir la aplicación.

Los CRUD se dan por validados manualmente según el usuario. Esta confirmación no acredita por sí sola las operaciones adicionales ni la instalación del APK final.

`00_VALIDACION_ESTATICA.txt` pertenece al ejemplo GeoRescue y no debe presentarse como validación actual de Urban Signs.

## Hallazgos que deben resolverse o comprobarse

1. **Documentación heredada:** `docs/MANUAL_USUARIO.md` explica crear reportes con categoría y severidad. `docs/00_EMPEZAR_AQUI.md` y `docs/05_PRUEBAS_Y_DEFENSA.md` también describen GeoRescue. Adaptar los documentos que se entreguen a cotizaciones y pedidos; identificar expresamente cualquier material de referencia que se conserve.
2. **Validación numérica incompleta:** ancho, alto y cantidad no tienen validadores explícitos en `quotation_form_screen.dart`; el anticipo tampoco en `order_form_screen.dart`. Hay conversiones con valores por defecto. Exigir números válidos y finitos, dimensiones/cantidad positivas, cantidad entera y anticipo entre cero y el total. Verificar también los abonos y el saldo restante.
3. **Conversión en dos operaciones:** `approveAndConvertToOrder` aprueba la cotización antes de crear el pedido. Probar un fallo entre ambas operaciones y el reintento; evitar duplicados o dejar una recuperación clara que mantenga información coherente.
4. **Inicio LIVE:** `main.dart` espera la inicialización y carga del perfil antes de `runApp`; comprobar y manejar un fallo de configuración/red/perfil para evitar que impida abrir una interfaz con mensaje y recuperación.
5. **Archivos generados versionados:** hay 10 archivos de `android/.gradle` bajo control de versiones. Retirarlos del índice y excluirlos en la etapa de limpieza, conservando los archivos locales necesarios.
6. **Firma Release:** Gradle usa una firma Release si existe `android/key.properties`; de lo contrario usa la de debug. Confirmar la configuración para la entrega e instalar el resultado. El PDF exige APK Release funcional, pero no impone publicación en una tienda ni una firma comercial específica.

## Plan de trabajo por etapas

El orden es la planificación base; no se fija una fecha de entrega porque todavía no se proporcionó. Cada tarea se marca solo después de comprobar su criterio de cierre. Responsables: desarrollo para código/documentación/build; autor para cuentas, acceso del docente, revisión de datos y presentación. Las pruebas en Android pueden ejecutarse cuando haya dispositivo o emulador disponible.

### Etapa 1. Completar coherencia y validaciones

- [ ] P01. Actualizar manual de usuario, pruebas, guía de inicio y demás documentos entregados a Urban Signs; ajustar descripción de `pubspec.yaml`. Cierre: las instrucciones corresponden a pantallas y funciones existentes.
- [ ] P02. Completar validación numérica de cotizaciones, anticipos y abonos. Cierre: entradas vacías, texto, cero indebido, negativos, valores no finitos y sobrepagos se rechazan con mensajes claros.
- [ ] P03. Probar y corregir recuperación del inicio LIVE y conversión cotización-pedido. Cierre: fallos previsibles no dejan al usuario sin respuesta y los reintentos no duplican pedidos.
- [ ] P04. Agregar pruebas relevantes de las correcciones y de la lógica de conversión/abonos. Ejecutar análisis y pruebas. Cierre: todo aprobado y resultados registrados.

### Etapa 2. Comprobar el flujo en Android

Depende de P02-P04 y de disponer de Android y acceso al proyecto Supabase para LIVE.

- [ ] P05. Recorrer DEMO: entrar, crear/editar/eliminar cotización, convertir, consultar/editar pedido, cambiar estado y registrar abono. Cierre: navegación y totales correctos, sin errores inesperados.
- [ ] P06. Completar recorrido LIVE (avance parcial). **CRUD de cotizaciones y pedidos completado según confirmación manual del usuario**; ver casillas anteriores. Pendiente: registro/login válido e inválido, conversión, abonos, cierre de sesión y persistencia tras reinicio. Cierre: los datos se mantienen y la sesión funciona según lo documentado.
- [ ] P07. Probar imágenes/Storage, GPS, mapa, clima, WhatsApp y preferencias. Cierre: integraciones demostradas y permisos denegados/fallo de servicio manejados.
- [ ] P08. Comprobar permisos de usuario y administrador con cuentas de prueba y RLS. Cierre: las acciones permitidas funcionan y las prohibidas no modifican datos.
- [ ] P09. Registrar cada caso con resultado real, fecha, dispositivo/modo y evidencia. Corregir fallos y repetir únicamente lo afectado antes del build final.

### Etapa 3. Preparar repositorio y documentación final

Puede comenzar con P01; el cierre depende de los resultados de la etapa 2.

- [ ] P10. Limpiar archivos generados del índice y revisar secretos en contenido e historial sin exponerlos en registros. Cierre: repositorio y futura entrega sin archivos sensibles ni cachés innecesarias.
- [ ] P11. Guardar etapas reales en commits descriptivos durante el trabajo y subir los cambios autorizados al repositorio. Cierre: el historial publicado muestra las mejoras sucesivas. No fabricar historia del trabajo pasado.
- [ ] P12. Validar README desde una copia limpia, incluyendo configuración, requisitos y limitaciones reales. Cierre: otra persona puede seguirlo sin explicaciones adicionales.
- [ ] P13. Crear `REPOSITORIO.txt` con `https://github.com/Fer140421/App---URBAN-SIGNS` y confirmar acceso del evaluador. Cierre: el enlace permite revisar código, README e historial actualizado.

### Etapa 4. Generar e instalar el APK final

Depende del cierre funcional de la etapa 2.

- [ ] P14. Ejecutar comprobaciones finales: `flutter pub get`, `flutter analyze`, `flutter test`; guardar evidencia legible de resultados. Cierre: comandos exitosos sobre la versión que se compilará.
- [ ] P15. Generar `flutter build apk --release --dart-define-from-file=config/live.json`. Cierre: build exitoso y archivo `build/app/outputs/flutter-apk/app-release.apk` existente. Usar LIVE para respaldar la persistencia declarada por este proyecto; el PDF no exige Supabase específicamente.
- [ ] P16. Copiar el APK como `APK/UrbanSigns_1.0.0_release.apk`, instalarlo, abrirlo desde el icono y repetir el flujo principal. Cierre: el mismo APK que se entregará funciona sin `flutter run`.

### Etapa 5. Completar evidencias y entrega

Las capturas se recopilan durante las etapas anteriores, no se simulan al final.

- [ ] P17. Completar las 11 evidencias de la tabla siguiente; revisar legibilidad, contexto y datos de prueba.
- [ ] P18. Preparar `PROYECTO_FINAL_CAMATA_DAAVID/` con `APK/`, `EVIDENCIAS/`, `README.md` y `REPOSITORIO.txt`. Comprimir si corresponde a la plataforma.
- [ ] P19. Revisar el paquete completo desde la perspectiva del evaluador: leer README, abrir repositorio, instalar APK y demostrar funciones. Cierre: los diez puntos del checklist oficial están respaldados por evidencia.

## Evidencias obligatorias (sección 6)

| ID | Archivo sugerido en `evidencias/` | Debe demostrar | Estado |
|---|---|---|---|
| E01 | `01_app_ejecutando.png` | Proyecto ejecutándose | Pendiente |
| E02 | `02_pantallas_principales.png` | Pantallas principales; usar varias capturas si hace falta | Pendiente |
| E03 | `03_flujo_principal.png` | Navegación y cotización-pedido-abono; secuencia de capturas si hace falta | Pendiente |
| E04 | `04_git_commits.png` | Repositorio e historial progresivo real | Pendiente |
| E05 | `05_readme_repositorio.png` | README visible en el repositorio | Pendiente |
| E06 | `06_comprobaciones.png` | Comprobaciones previas al build y sus resultados | Pendiente |
| E07 | `07_build_release.png` | Generación exitosa del APK Release | Pendiente |
| E08 | `08_ubicacion_apk.png` | Archivo APK generado y ubicación | Pendiente |
| E09 | `09_instalacion_apk.png` | Instalación del APK final | Pendiente |
| E10 | `10_apertura_dispositivo.png` | App abierta desde el icono después de instalar | Pendiente |
| E11 | `11_integraciones_*.png` | Integraciones relevantes: Supabase/persistencia, Storage, GPS/mapa, clima, WhatsApp | Pendiente |

## Checklist oficial de cierre (sección 10)

- [ ] 1. La aplicación abre y funciona (P05-P09, P16). Avance: apertura y CRUD confirmados por el usuario en su sesión LIVE; falta validación del resto de funciones declaradas y del APK final en Android.
- [ ] 2. El flujo principal puede demostrarse (P05-P09, P16). Avance: CRUD confirmado; pendiente confirmar conversión, abonos y evidencias del recorrido completo.
- [ ] 3. El repositorio tiene commits progresivos (P11).
- [ ] 4. El README está completo y actualizado en la versión publicada (P01, P12).
- [ ] 5. El APK fue generado en Release (P14-P15).
- [ ] 6. El APK fue instalado y probado (P16).
- [ ] 7. Las capturas muestran el proceso completo (P17).
- [ ] 8. El enlace al repositorio funciona para revisión (P13).
- [ ] 9. No se publicaron secretos o credenciales sensibles (P10, P18).
- [ ] 10. Los archivos están correctamente identificados (P18-P19).

Aunque el README cumple el contenido mínimo local, su casilla de cierre queda pendiente hasta validar y publicar la versión final.

## Registro de avance

Incidencia de aprobación (2026-09-05): la captura mostró `LocaleDataException` al construir la fecha del diálogo. Se agregó `await initializeDateFormatting('es')` antes de abrir la app en `lib/main.dart`; también cubre las fechas en español del formulario y detalle de pedidos. Análisis sin incidencias. Pendiente reiniciar la aplicación y verificar apertura del diálogo y conversión en LIVE; no se marca P06 como completado por esta corrección.

| Fecha | Trabajo realizado | Resultado | Próximo paso |
|---|---|---|---|
| 2026-09-05 | Usuario confirma funcionamiento de todos los CRUD en el contexto de su sesión LIVE | Crear, consultar, actualizar y eliminar cotizaciones y pedidos marcados como completados por validación manual del usuario; P06 queda parcialmente completado | Confirmar conversión, abonos y persistencia tras reiniciar; registrar dispositivo y capturas |
| 2026-09-05 | Revisión de lineamientos, código, documentación, Git y entregables; análisis y pruebas | Análisis sin incidencias; 4 pruebas aprobadas; diagnóstico y planificación guardados | P01-P04: coherencia documental, validaciones y recuperación de errores |
| 2026-09-05 | Investigación de cotización desaparecida: carga de cotizaciones/pedidos al entrar a MainShell, incluso con sesión restaurada; configuración VS Code SUPABASE corregida de `config/local.json` inexistente a `config/live.json` | Corregidas dos causas posibles; no se verificó la fila del usuario en Supabase ni se confirmó el modo de su sesión | Validar P06: comprobar modo LIVE, actualizar sin filtros y reiniciar para confirmar persistencia |

Para continuar en otra sesión: abrir este archivo, leer el punto actual y tomar la primera tarea pendiente. Al cerrar una tarea, marcar su casilla, añadir evidencia y actualizar esta tabla. La existencia del código no sustituye una prueba funcional ni una captura de entrega.
