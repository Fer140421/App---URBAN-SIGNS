import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/orders_controller.dart';
import '../../core/utils/app_constants.dart';
import '../../models/order.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.id});

  final String id;

  Color _statusColor(String status) {
    return switch (status) {
      'en_diseno' => const Color(0xFFBA68C8),
      'en_produccion' => const Color(0xFF42A5F5),
      'listo_para_entrega' => const Color(0xFFFFB300),
      'instalado_entregado' => const Color(0xFF00E676),
      'cancelado' => const Color(0xFFFF5252),
      _ => const Color(0xFFFFC400),
    };
  }

  String _statusTitle(String status) {
    return switch (status) {
      'en_diseno' => 'EN DISEÑO',
      'en_produccion' => 'EN PRODUCCIÓN',
      'listo_para_entrega' => 'LISTO PARA ENTREGA',
      'instalado_entregado' => 'ENTREGADO / INSTALADO',
      'cancelado' => 'CANCELADO',
      _ => status.toUpperCase(),
    };
  }

  Future<void> _changeStatus(BuildContext context, OrdersController controller, Order order, String nextStatus) async {
    try {
      await controller.updateStatus(order.id, nextStatus);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Estado actualizado a ${_statusTitle(nextStatus)}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo actualizar el estado: $e')),
        );
      }
    }
  }

  Future<void> _registerPaymentDialog(BuildContext context, OrdersController controller, Order order) async {
    final currency = NumberFormat.currency(symbol: 'Bs. ', decimalDigits: 2);
    final amountCtrl = TextEditingController(text: order.balanceDue.toStringAsFixed(2));

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF181C1D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFF2C3233)),
        ),
        title: const Text(
          'Registrar Abono / Pago de Saldo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saldo pendiente actual: ${currency.format(order.balanceDue)}',
              style: const TextStyle(color: Color(0xFFA0A7A7), fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Color(0xFFFFC400), fontWeight: FontWeight.w900, fontSize: 16),
              decoration: const InputDecoration(
                labelText: 'Monto a Abonar (Bs.)',
                prefixText: 'Bs. ',
                prefixStyle: TextStyle(color: Color(0xFFFFC400), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFFA0A7A7))),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFFC400),
              foregroundColor: Colors.black,
            ),
            child: const Text('Registrar Abono', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final amount = double.tryParse(amountCtrl.text) ?? 0.0;
      if (amount <= 0) return;
      try {
        await controller.registerPayment(order.id, amount);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pago de ${currency.format(amount)} registrado con éxito.')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  Future<void> _notifyWhatsApp(BuildContext context, Order order) async {
    final text = Uri.encodeComponent(
      '👋 Hola *${order.clientName}*, le informamos sobre el avance de su pedido *${order.orderNumber}* (*${order.projectTitle}*):\n\n'
      '📍 *Estado actual:* ${_statusTitle(order.status)}\n'
      '${order.deliveryDate != null ? '🗓️ *Fecha programada:* ${DateFormat('dd/MM/yyyy').format(order.deliveryDate!)}\n' : ''}'
      '💰 *Saldo pendiente:* Bs. ${order.balanceDue.toStringAsFixed(2)}\n\n'
      '¡Gracias por confiar en *${AppConstants.appName}*!',
    );

    final cleanPhone = order.clientPhone.replaceAll(RegExp(r'[^0-9]'), '');
    final url = Uri.parse('https://wa.me/$cleanPhone?text=$text');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo abrir WhatsApp.')));
      }
    }
  }

  Future<void> _delete(BuildContext context, OrdersController controller, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF181C1D),
        title: const Text('Eliminar Pedido', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        content: const Text('¿Estás seguro de eliminar esta orden de trabajo?', style: TextStyle(color: Color(0xFFA0A7A7))),
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pedido eliminado.')));
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
    final controller = context.watch<OrdersController>();
    final app = context.watch<AppController>();
    final order = controller.byId(id);
    final currency = NumberFormat.currency(symbol: 'Bs. ', decimalDigits: 2);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle de Pedido')),
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

    final canEdit = app.canEdit(order.ownerId);
    final statusColor = _statusColor(order.status);
    final point = (order.latitude != null && order.longitude != null)
        ? LatLng(order.latitude!, order.longitude!)
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFF101313),
      appBar: AppBar(
        title: Text('Orden ${order.orderNumber}'),
        actions: [
          IconButton(
            onPressed: () => _notifyWhatsApp(context, order),
            icon: const Icon(Icons.send_outlined, color: Color(0xFF00E676)),
            tooltip: 'Notificar por WhatsApp',
          ),
          if (canEdit)
            IconButton(
              onPressed: () => context.push('/orders/${order.id}/edit', extra: order),
              icon: const Icon(Icons.edit_outlined, color: Color(0xFFFFC400)),
              tooltip: 'Editar',
            ),
          if (canEdit)
            IconButton(
              onPressed: () => _delete(context, controller, order.id),
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Eliminar',
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          if (order.imageUrl != null && order.imageUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  order.imageUrl!,
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

          // Cabecera Principal de Orden
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC400),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        order.orderNumber,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        _statusTitle(order.status),
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  order.projectTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Cliente: ${order.clientName}', style: const TextStyle(color: Color(0xFFD2D7D7), fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Selector de Estado de Producción
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF181C1D),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2B3133), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Control de Etapa en Taller',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _StageChip(
                        label: 'En Diseño',
                        active: order.status == 'en_diseno',
                        color: const Color(0xFFBA68C8),
                        onTap: () => _changeStatus(context, controller, order, 'en_diseno'),
                      ),
                      const SizedBox(width: 6),
                      _StageChip(
                        label: 'En Producción',
                        active: order.status == 'en_produccion',
                        color: const Color(0xFF42A5F5),
                        onTap: () => _changeStatus(context, controller, order, 'en_produccion'),
                      ),
                      const SizedBox(width: 6),
                      _StageChip(
                        label: 'Listo p/ Entrega',
                        active: order.status == 'listo_para_entrega',
                        color: const Color(0xFFFFB300),
                        onTap: () => _changeStatus(context, controller, order, 'listo_para_entrega'),
                      ),
                      const SizedBox(width: 6),
                      _StageChip(
                        label: 'Instalado / Entregado',
                        active: order.status == 'instalado_entregado',
                        color: const Color(0xFF00E676),
                        onTap: () => _changeStatus(context, controller, order, 'instalado_entregado'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Control Financiero
          Container(
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Estado de Pagos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                    if (!order.isPaidInFull)
                      FilledButton.icon(
                        onPressed: () => _registerPaymentDialog(context, controller, order),
                        icon: const Icon(Icons.payment_outlined, size: 16),
                        label: const Text('Abonar Saldo'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC400),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _RowItem(label: 'Total Pedido:', value: currency.format(order.totalAmount)),
                _RowItem(label: 'Anticipo Pagado:', value: currency.format(order.advancePayment)),
                _RowItem(
                  label: 'Saldo Pendiente:',
                  value: order.isPaidInFull ? '✓ PAGADO TOTAL' : currency.format(order.balanceDue),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: order.totalAmount > 0 ? (order.advancePayment / order.totalAmount).clamp(0.0, 1.0) : 1.0,
                    minHeight: 7,
                    backgroundColor: const Color(0xFF331E20),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      order.isPaidInFull ? const Color(0xFF00E676) : const Color(0xFFFFC400),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Especificaciones
          _DetailCard(
            title: 'Detalles de Fabricación',
            icon: Icons.construction_outlined,
            children: [
              Text(order.specifications, style: const TextStyle(color: Color(0xFFD2D7D7), height: 1.4, fontSize: 13)),
              if (order.deliveryDate != null) ...[
                const SizedBox(height: 10),
                _RowItem(
                  label: 'Fecha Comprometida de Entrega',
                  value: DateFormat('dd/MM/yyyy (EEEE)', 'es').format(order.deliveryDate!),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),

          // Cliente
          _DetailCard(
            title: 'Datos de Contacto',
            icon: Icons.contact_phone_outlined,
            children: [
              _RowItem(label: 'Cliente', value: order.clientName),
              _RowItem(label: 'Teléfono', value: order.clientPhone),
            ],
          ),
          const SizedBox(height: 14),

          // Ubicación
          if (order.deliveryAddress != null || point != null) ...[
            _DetailCard(
              title: 'Lugar de Montaje / Instalación',
              icon: Icons.location_on_outlined,
              children: [
                if (order.deliveryAddress != null)
                  Text(order.deliveryAddress!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
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
            title: 'Trazabilidad',
            icon: Icons.history_outlined,
            children: [
              if (order.quotationId != null) ...[
                _RowItem(label: 'Cotización Origen', value: order.quotationId!),
                const SizedBox(height: 4),
              ],
              _RowItem(label: 'Fecha de Creación', value: DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt)),
              _RowItem(label: 'Última Actualización', value: DateFormat('dd/MM/yyyy HH:mm').format(order.updatedAt)),
              _RowItem(label: 'ID de Orden', value: order.id),
            ],
          ),
        ],
      ),
    );
  }
}

class _StageChip extends StatelessWidget {
  const _StageChip({
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.25) : const Color(0xFF1E2223),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? color : const Color(0xFF2C3233)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? color : const Color(0xFFA0A7A7),
            fontWeight: active ? FontWeight.w900 : FontWeight.w600,
            fontSize: 11.5,
          ),
        ),
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
