# GRAFIK 360 PRO · Gestión para Industria Gráfica y Publicidad

Aplicación Flutter profesional para la administración de **Talleres Gráficos, Publicidad Exterior, Banners, Stands, Letreros en Acrílico, Rotulación y Producción**.

---

## 🚀 Módulos y Funcionalidades Principales

1. **Autenticación y Perfiles de Taller**:
   - Login y Registro con Supabase Auth / Modo Demostración sin conexión.
   - Roles (`user` / `admin`) y control de acceso por usuario (RLS).
2. **Módulo Completo de Cotizaciones (CRUD)**:
   - Registro de cotizaciones para: *Banners y Gigantografías, Stands Publicitarios, Letreros en Acrílico, Rotulación y Vinilos, Letras Corpóreas / Neón LED, etc.*
   - Cálculo dinámico de área ($m^2$), cantidad, precio unitario y precio total.
   - Adjunto de boceto / referencia visual (Supabase Storage).
   - Compartir cotización pre-formateada directamente al cliente por **WhatsApp**.
3. **Flujo de Cotización a Pedido de Producción**:
   - Botón **"Aprobar y Crear Pedido"**: al aprobar una cotización, se solicita el anticipo recibido y la fecha comprometida de entrega, generando automáticamente la orden de producción vinculada.
4. **Módulo Completo de Pedidos de Producción (CRUD)**:
   - Seguimiento del ciclo de taller: `En Diseño` ➔ `En Producción` ➔ `Listo p/ Entrega` ➔ `Entregado / Instalado`.
   - Control financiero: Monto Total, Anticipo Pagado y Saldo Pendiente.
   - Registro de abonos / pagos adicionales.
   - Notificación de avance al cliente por WhatsApp.
5. **Georreferenciación y Mapa de Instalaciones**:
   - Ubicación GPS y mapa interactivo con OpenStreetMap (`flutter_map`) para montaje en sitio.
6. **Dashboard y Métricas en Tiempo Real**:
   - Cotizaciones activas, pedidos en taller, entregas pendientes y total de saldos por cobrar.

---

## 📦 1. Arranque Inmediato (Modo DEMO)

Puedes ejecutar la app inmediatamente sin configurar Supabase:

```bash
flutter run --dart-define=DEMO_MODE=true
```

---

## 🗄️ 2. Conectar con Supabase (Modo LIVE)

### Paso A: Ejecutar el Script SQL en Supabase
1. Ingresa a tu panel de **Supabase** ([supabase.com](https://supabase.com)).
2. Ve a la sección **SQL Editor** de tu proyecto.
3. Copia y pega el contenido de [`supabase/01_schema_completo.sql`](file:///C:/sistemas_desarrollo/DIPLOMADO/GEORESCUE_360_PRO_TRABAJO_FINAL_EJEMPLO%20%281%29/PROYECTO_FINAL_EJEMPLO_GEORESCUE_360_PRO/supabase/01_schema_completo.sql) y pulsa **Run**.
   - Crea las tablas `profiles`, `quotations`, `orders`.
   - Configura las políticas RLS y triggers automáticos de actualización y nuevo usuario.
   - Crea el bucket público de almacenamiento `graphic-assets` con políticas de subida.
4. *(Opcional)* Si deseas cargar datos de prueba reales para la industria gráfica, ejecuta [`supabase/02_datos_demo_opcional.sql`](file:///C:/sistemas_desarrollo/DIPLOMADO/GEORESCUE_360_PRO_TRABAJO_FINAL_EJEMPLO%20%281%29/PROYECTO_FINAL_EJEMPLO_GEORESCUE_360_PRO/supabase/02_datos_demo_opcional.sql) después de haberte registrado.

### Paso B: Configurar las Credenciales
1. Edita el archivo `config/live.json` (o crea uno basado en `config/live.example.json`):
```json
{
  "DEMO_MODE": "false",
  "SUPABASE_URL": "https://TU_PROYECTO.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "TU_PUBLISHABLE_KEY_ANON"
}
```

### Paso C: Ejecutar en Modo LIVE
```bash
flutter run --dart-define-from-file=config/live.json
```

---

## 🧪 Pruebas Automatizadas y Calidad de Código

```bash
flutter analyze
flutter test
```
*(Ambos pasan al 100% con cero errores y advertencias).*
