import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/orders_controller.dart';
import '../../controllers/quotations_controller.dart';
import '../../core/utils/app_constants.dart';
import '../../models/quotation.dart';

class QuotationDetailScreen extends StatelessWidget {
  const QuotationDetailScreen({super.key, required this.id});

  final String id;

  Color _statusColor(String status) {
    return switch (status) {
      'aprobada' => const Color(0xFF00E676),
      'pendiente' => const Color(0xFFFFC400),
      'borrador' => const Color(0xFF90A4AE),
      'rechazada' => const Color(0xFFFF5252),
      _ => const Color(0xFFFFC400),
    };
  }

  Future<void> _shareWhatsApp(BuildContext context, Quotation quote) async {
    final currency = NumberFormat.currency(symbol: 'Bs. ', decimalDigits: 2);
    final text = Uri.encodeComponent(
      '👋 Hola *${quote.clientName}*, le enviamos el detalle de su cotización de *${AppConstants.appName}*:\n\n'
      '📌 *Proyecto:* ${quote.projectTitle}\n'
      '🏷️ *Servicio:* ${quote.serviceType}\n'
      '📐 *Medidas:* ${quote.widthMeters.toStringAsFixed(2)}m x ${quote.heightMeters.toStringAsFixed(2)}m\n'
      '🔢 *Cantidad:* ${quote.quantity} unidad(es)\n'
      '💰 *Precio Total:* ${currency.format(quote.totalAmount)}\n\n'
      '📝 *Detalles:* ${quote.description}\n'
      '${quote.notes != null ? '⏳ *Condiciones:* ${quote.notes}\n' : ''}'
      '\nQuedamos a su disposición para iniciar la producción.',
    );

    final cleanPhone = quote.clientPhone.replaceAll(RegExp(r'[^0-9]'), '');
    final url = Uri.parse('https://wa.me/$cleanPhone?text=$text');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir WhatsApp.')),
        );
      }
    }
  }

  Future<void> _showConvertToOrderDialog(BuildContext context, Quotation quote) async {
    final advanceCtrl = TextEditingController(text: (quote.totalAmount * 0.5).toStringAsFixed(2));
    final notesCtrl = TextEditingController(text: quote.notes ?? '');
    DateTime selectedDate = DateTime.now().add(const Duration(days: 3));

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: const Color(0xFF181C1D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFF2C3233)),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Color(0xFF00E676)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Aprobar y Crear Pedido',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Se generará automáticamente una Orden de Trabajo en el módulo de Pedidos.',
                  style: TextStyle(color: Color(0xFFA0A7A7), fontSize: 12),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Anticipo / Adelanto Recibido *',
                  style: TextStyle(color: Color(0xFFD2D7D7), fontSize: 12, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: advanceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Color(0xFFFFC400), fontWeight: FontWeight.w800, fontSize: 15),
                  decoration: InputDecoration(
                    prefixText: 'Bs. ',
                    prefixStyle: const TextStyle(color: Color(0xFFFFC400), fontWeight: FontWeight.bold),
                    helperText: 'Total trabajo: Bs. ${quote.totalAmount.toStringAsFixed(2)}',
                    helperStyle: const TextStyle(color: Color(0xFFA0A7A7)),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Fecha de Entrega / Instalación',
                  style: TextStyle(color: Color(0xFFD2D7D7), fontSize: 12, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2425),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF2D3335)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined, color: Color(0xFFFFC400), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          DateFormat('dd/MM/yyyy (EEEE)', 'es').format(selectedDate),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setModalState(() => selectedDate = picked);
                          }
                        },
                        child: const Text('Cambiar', style: TextStyle(color: Color(0xFFFFC400))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Instrucciones para Taller / Producción',
                  style: TextStyle(color: Color(0xFFD2D7D7), fontSize: 12, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: notesCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Ej. Prioridad para evento de fin de semana...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('Cancelar', style: TextStyle(color: Color(0xFFA0A7A7))),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(dialogCtx, true),
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Confirmar Pedido'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFC400),
                foregroundColor: Colors.black,
                textStyle: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final advance = double.tryParse(advanceCtrl.text) ?? 0.0;
        final quotesCtrl = context.read<QuotationsController>();
        final ordersCtrl = context.read<OrdersController>();

        final newOrder = await quotesCtrl.approveAndConvertToOrder(
          quotation: quote,
          ordersController: ordersCtrl,
          advancePayment: advance,
          deliveryDate: selectedDate,
          notes: notesCtrl.text.trim(),
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('¡Cotización aprobada! Creado pedido ${newOrder.orderNumber}')),
          );
          context.pushReplacement('/orders/${newOrder.id}');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al procesar: $e')),
          );
        }
      }
    }
  }

  Future<void> _delete(BuildContext context, QuotationsController controller, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF181C1D),
        title: const Text('Eliminar Cotización', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        content: const Text('¿Estás seguro de eliminar este registro permanentemente?', style: TextStyle(color: Color(0xFFA0A7A7))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx, false), child: const Text('Cancelar', style: TextStyle(color: Color(0xFFA0A7A7)))),
          FilledButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await controller.delete(id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cotización eliminada.')));
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo eliminar: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<QuotationsController>();
    final app = context.watch<AppController>();
    final quote = controller.byId(id);
    final currency = NumberFormat.currency(symbol: 'Bs. ', decimalDigits: 2);

    if (quote == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle de Cotización')),
        body: Center(
          child: FilledButton.tonalIcon(
            onPressed: () async {
              await controller.load();
              if (context.mounted) context.pop();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Actualizar y volver'),
          ),
        ),
      );
    }

    final canEdit = app.canEdit(quote.ownerId);
    final statusColor = _statusColor(quote.status);
    final point = (quote.latitude != null && quote.longitude != null)
        ? LatLng(quote.latitude!, quote.longitude!)
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFF101313),
      appBar: AppBar(
        title: const Text('Detalle de Cotización'),
        actions: [
          IconButton(
            onPressed: () => _shareWhatsApp(context, quote),
            icon: const Icon(Icons.send_outlined, color: Color(0xFF00E676)),
            tooltip: 'Compartir por WhatsApp',
          ),
          if (canEdit)
            IconButton(
              onPressed: () => context.push('/quotations/${quote.id}/edit', extra: quote),
              icon: const Icon(Icons.edit_outlined, color: Color(0xFFFFC400)),
              tooltip: 'Editar',
            ),
          if (canEdit)
            IconButton(
              onPressed: () => _delete(context, controller, quote.id),
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Eliminar',
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          if (quote.imageUrl != null && quote.imageUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  quote.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: const Color(0xFF1E2223),
                    child: const Center(child: Icon(Icons.broken_image_outlined, size: 48, color: Colors.grey)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Cabecera Principal y Presupuesto
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF181C1D),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2B3133), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        quote.status.toUpperCase(),
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 11),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF262B2C),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        quote.serviceType,
                        style: const TextStyle(color: Color(0xFFE0E5E5), fontWeight: FontWeight.w700, fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  quote.projectTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131617),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF24292B)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Monto Total Presupuestado:', style: TextStyle(color: Color(0xFFA0A7A7), fontSize: 13)),
                      Text(
                        currency.format(quote.totalAmount),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFFC400),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Botón Principal: Aprobar y Convertir en Pedido
          if (quote.status != 'aprobada') ...[
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: () => _showConvertToOrderDialog(context, quote),
                icon: const Icon(Icons.check_circle_outline, size: 22),
                label: const Text('APROBAR Y CREAR PEDIDO DE PRODUCCIÓN'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC400),
                  foregroundColor: Colors.black,
                  textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Datos del Cliente
          _DetailCard(
            title: 'Datos del Cliente',
            icon: Icons.person_outline,
            children: [
              _RowItem(label: 'Cliente / Razón Social', value: quote.clientName),
              _RowItem(label: 'WhatsApp / Teléfono', value: quote.clientPhone),
              if (quote.clientEmail != null && quote.clientEmail!.isNotEmpty)
                _RowItem(label: 'Correo Electrónico', value: quote.clientEmail!),
            ],
          ),
          const SizedBox(height: 14),

          // Medidas y Costos
          _DetailCard(
            title: 'Especificaciones y Medidas',
            icon: Icons.aspect_ratio,
            children: [
              _RowItem(
                label: 'Dimensiones (Ancho × Alto)',
                value: '${quote.widthMeters.toStringAsFixed(2)} m × ${quote.heightMeters.toStringAsFixed(2)} m',
              ),
              _RowItem(
                label: 'Área Total Calculada',
                value: '${quote.areaSquareMeters.toStringAsFixed(2)} m²',
              ),
              _RowItem(label: 'Cantidad', value: '${quote.quantity} unidad(es)'),
              _RowItem(label: 'Precio Unitario', value: currency.format(quote.unitPrice)),
              const SizedBox(height: 10),
              const Text('Descripción Técnica:', style: TextStyle(color: Color(0xFFFFC400), fontWeight: FontWeight.w800, fontSize: 12)),
              const SizedBox(height: 4),
              Text(quote.description, style: const TextStyle(color: Color(0xFFD2D7D7), height: 1.4, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 14),

          // Notas y Condiciones
          if (quote.notes != null && quote.notes!.isNotEmpty) ...[
            _DetailCard(
              title: 'Condiciones de Entrega y Notas',
              icon: Icons.info_outline,
              children: [Text(quote.notes!, style: const TextStyle(color: Color(0xFFD2D7D7), height: 1.4, fontSize: 13))],
            ),
            const SizedBox(height: 14),
          ],

          // Ubicación de Instalación
          if (quote.deliveryAddress != null || point != null) ...[
            _DetailCard(
              title: 'Lugar de Instalación / Montaje',
              icon: Icons.location_on_outlined,
              children: [
                if (quote.deliveryAddress != null)
                  Text(quote.deliveryAddress!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                if (point != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 180,
                      child: FlutterMap(
                        options: MapOptions(initialCenter: point, initialZoom: 15),
                        children: [
                          TileLayer(
                            urlTemplate: AppConstants.osmUrl,
                            userAgentPackageName: 'bo.edu.uajms.georescue360',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: point,
                                width: 44,
                                height: 44,
                                child: const Icon(Icons.location_on, color: Colors.redAccent, size: 40),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),
          ],

          // Trazabilidad
          _DetailCard(
            title: 'Trazabilidad del Registro',
            icon: Icons.history_outlined,
            children: [
              _RowItem(label: 'Fecha de creación', value: DateFormat('dd/MM/yyyy HH:mm').format(quote.createdAt)),
              _RowItem(label: 'Última actualización', value: DateFormat('dd/MM/yyyy HH:mm').format(quote.updatedAt)),
              _RowItem(label: 'ID Registro', value: quote.id),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.title, required this.icon, required this.children});
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF181C1D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2B3133), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFFFFC400)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  const _RowItem({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFFA0A7A7), fontSize: 12.5)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}
