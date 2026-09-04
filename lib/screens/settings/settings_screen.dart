import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/app_controller.dart';
import '../../core/utils/app_constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes y Configuración')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        children: [
          // Tarjeta de perfil
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      app.fullName.isEmpty ? 'G' : app.fullName.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app.fullName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        Text(app.currentUserEmail),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: app.demoMode ? Colors.amber.shade100 : Colors.green.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            app.demoMode ? 'MODO DEMOSTRACIÓN' : 'CONECTADO A SUPABASE (${app.role.toUpperCase()})',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: app.demoMode ? Colors.amber.shade900 : Colors.green.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Preferencias de la app
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: app.darkMode,
                  onChanged: app.setDarkMode,
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Tema oscuro'),
                  subtitle: const Text('Persistido localmente con SharedPreferences.'),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: app.compactCards,
                  onChanged: app.setCompactCards,
                  secondary: const Icon(Icons.view_agenda_outlined),
                  title: const Text('Tarjetas compactas'),
                  subtitle: const Text('Visualización densa de cotizaciones y pedidos.'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Stack Técnico del proyecto
          const _TechCard(),
          const SizedBox(height: 14),

          // Flujo de trabajo del taller
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Flujo Operativo de la App',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '1. Registra o inicia sesión.\n'
                    '2. Crea una cotización con medidas y precio calculado.\n'
                    '3. Envía el presupuesto al cliente por WhatsApp.\n'
                    '4. Al aprobar la cotización, haz clic en "Aprobar y Crear Pedido".\n'
                    '5. Define el anticipo recibido y la fecha de entrega.\n'
                    '6. Monitorea el pedido en taller (Diseño -> Producción -> Entrega).\n'
                    '7. Registra abonos y evidencia fotográfica en Supabase Storage.',
                    style: TextStyle(height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          OutlinedButton.icon(
            onPressed: () async {
              await app.signOut();
              if (!context.mounted) return;
              context.go('/');
            },
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}

class _TechCard extends StatelessWidget {
  const _TechCard();

  @override
  Widget build(BuildContext context) {
    const tech = [
      ('Flutter 3.x + Material 3', 'Frontend multiplataforma responsivo'),
      ('Provider State Management', 'Gestión reactiva de cotizaciones y pedidos'),
      ('Supabase PostgreSQL + RLS', 'Base de datos con tablas quotations, orders y profiles'),
      ('Supabase Storage', 'Almacenamiento de bocetos y fotos de producción'),
      ('Geolocator + OSM (flutter_map)', 'Georreferenciación de puntos de montaje'),
      ('URL Launcher (WhatsApp Integration)', 'Envío instantáneo de cotizaciones y avisos'),
      ('GoRouter', 'Navegación declarativa y paso de parámetros'),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppConstants.appName} · Stack Técnico',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            ...tech.map((item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: const Icon(Icons.check_circle_outline, color: Color(0xFF00C853)),
                  title: Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(item.$2),
                )),
          ],
        ),
      ),
    );
  }
}
