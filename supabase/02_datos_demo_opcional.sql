-- ============================================================
-- GRAFIK 360 PRO · DATOS DEMO OPCIONALES
-- Ejecutar en SQL Editor de Supabase después de tener al menos
-- 1 usuario registrado en auth.users.
-- Reemplaza 'TU_USER_UUID_AQUI' por tu UUID de Authentication > Users.
-- ============================================================

do $$
declare
  target_user_id uuid;
begin
  -- Obtener el primer usuario registrado en la base de datos
  select id into target_user_id from auth.users order by created_at asc limit 1;

  if target_user_id is null then
    raise notice 'No hay usuarios registrados en auth.users. Regístrate primero desde la app o el panel de Supabase.';
    return;
  end if;

  -- Cotización 1: Letrero Acrílico
  insert into public.quotations (
    id, owner_id, client_name, client_phone, client_email, project_title, service_type,
    description, width_meters, height_meters, quantity, unit_price, total_amount, status,
    notes, delivery_address, latitude, longitude, image_url
  ) values (
    'a0000000-0000-0000-0000-000000000001',
    target_user_id,
    'Restaurante & Grill El Fogón',
    '+591 71234567',
    'contacto@elfogon.com',
    'Letrero Frontal en Acrílico Backlight LED',
    'Letreros en Acrílico',
    'Letrero de 3.20m x 1.00m en caja metálica de aluminio, frontal acrílico opalino 3mm con vinil translúcido e iluminación interna de módulos LED IP67.',
    3.20, 1.00, 1, 2450.00, 2450.00, 'aprobada',
    'Incluye estructura y montaje en fachada principal. Tiempo de fabricación: 4 días hábiles.',
    'Av. Las Américas #450, Tarija',
    -21.5332, -64.7340,
    'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=800&q=80'
  ) on conflict (id) do nothing;

  -- Cotización 2: Stand Publicitario
  insert into public.quotations (
    id, owner_id, client_name, client_phone, client_email, project_title, service_type,
    description, width_meters, height_meters, quantity, unit_price, total_amount, status,
    notes, delivery_address, latitude, longitude, image_url
  ) values (
    'a0000000-0000-0000-0000-000000000002',
    target_user_id,
    'Banco Ganadero / Eventos Especiales',
    '+591 76543210',
    'marketing@bancoganadero.bo',
    'Stands Publicitarios Modulares & Roll-Ups',
    'Stands Publicitarios',
    'Stand modular para feria de 3x3 metros: trasera en lona mate 13oz tensada con perfiles de aluminio, counter de atención en MDF ploteado y 2 roll-up banners 85x200cm.',
    3.00, 2.40, 1, 4800.00, 4800.00, 'pendiente',
    'Requiere entrega y armado el día previo a la inauguración de la Expo.',
    'Campo Ferial San Jacinto, Pabellón Internacional',
    -21.5580, -64.7210,
    'https://images.unsplash.com/photo-1511578314322-379afb476865?w=800&q=80'
  ) on conflict (id) do nothing;

  -- Pedido 1 (Derivado de Cotización 1): En producción
  insert into public.orders (
    id, owner_id, quotation_id, order_number, client_name, client_phone, project_title,
    service_type, specifications, total_amount, advance_payment, status, delivery_date,
    delivery_address, latitude, longitude, notes, image_url
  ) values (
    'b0000000-0000-0000-0000-000000000001',
    target_user_id,
    'a0000000-0000-0000-0000-000000000001',
    'PED-2026-001',
    'Restaurante & Grill El Fogón',
    '+591 71234567',
    'Letrero Frontal en Acrílico Backlight LED',
    'Letreros en Acrílico',
    '3.20m x 1.00m, caja aluminio, frontal acrílico opalino 3mm, iluminación LED IP67 12V con fuente hermética.',
    2450.00, 1500.00, 'en_produccion',
    now() + interval '2 days',
    'Av. Las Américas #450, Tarija',
    -21.5332, -64.7340,
    'Anticipo recibido del 60%. Montaje programado para viernes por la mañana.',
    'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=800&q=80'
  ) on conflict (id) do nothing;

  -- Pedido 2: Letras Corpóreas en Polyfan con Neón LED
  insert into public.orders (
    id, owner_id, quotation_id, order_number, client_name, client_phone, project_title,
    service_type, specifications, total_amount, advance_payment, status, delivery_date,
    delivery_address, latitude, longitude, notes, image_url
  ) values (
    'b0000000-0000-0000-0000-000000000002',
    target_user_id,
    null,
    'PED-2026-002',
    'Gimnasio PowerFit 360',
    '+591 72345678',
    'Letras Corpóreas en Polyfan con Neón LED Flexible',
    'Letras Corpóreas / Neón LED',
    'Logo POWERFIT de 2.00m x 0.60m en polyfan de 30mm pintado negro mate con silueta en neón LED amarillo/naranja.',
    1850.00, 1850.00, 'en_diseno',
    now() + interval '4 days',
    'Calle Ingavi #890, Tarija',
    -21.5310, -64.7290,
    'Pagado al 100%. Vectorizando tipografía para corte CNC.',
    'https://images.unsplash.com/photo-1550684848-fac1c5b4e853?w=800&q=80'
  ) on conflict (id) do nothing;

  raise notice 'Datos demo insertados correctamente para el usuario: %', target_user_id;
end $$;
