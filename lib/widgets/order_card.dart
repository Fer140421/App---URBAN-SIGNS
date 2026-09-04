import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/order.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
    this.compact = false,
  });

  final Order order;
  final VoidCallback onTap;
  final bool compact;

  Color _statusColor() {
    return switch (order.status) {
      'en_diseno' => const Color(0xFFBA68C8),
      'en_produccion' => const Color(0xFF42A5F5),
      'listo_para_entrega' => const Color(0xFFFFB300),
      'instalado_entregado' => const Color(0xFF00E676),
      'cancelado' => const Color(0xFFFF5252),
      _ => const Color(0xFFFFC400),
    };
  }

  String _statusLabel(String status) {
    return switch (status) {
      'en_diseno' => 'EN DISEÑO',
      'en_produccion' => 'EN PRODUCCIÓN',
      'listo_para_entrega' => 'LISTO P/ ENTREGA',
      'instalado_entregado' => 'ENTREGADO',
      'cancelado' => 'CANCELADO',
      _ => status.toUpperCase(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();
    final currency = NumberFormat.currency(symbol: 'Bs. ', decimalDigits: 2);
    final isPaid = order.isPaidInFull;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila 1: Badge # Orden, Título y Total
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC400),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      order.orderNumber,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.projectTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    currency.format(order.totalAmount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Fila 2: Cliente y Estado de Taller
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 14, color: Color(0xFFA0A7A7)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order.clientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFD2D7D7),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      _statusLabel(order.status),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Barra de Pago (Anticipo / Saldo)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: order.totalAmount > 0
                      ? (order.advancePayment / order.totalAmount).clamp(0.0, 1.0)
                      : 1.0,
                  minHeight: 5,
                  backgroundColor: const Color(0xFF331E20),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isPaid ? const Color(0xFF00E676) : const Color(0xFFFFC400),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Fila 3: Anticipo / Saldo y Fecha
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Anticipo: ${currency.format(order.advancePayment)}',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isPaid ? const Color(0xFF00E676) : const Color(0xFFFFD54F),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isPaid ? '✓ PAGADO' : 'Saldo: ${currency.format(order.balanceDue)}',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isPaid ? const Color(0xFF00E676) : const Color(0xFFFF5252),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  if (order.deliveryDate != null)
                    Row(
                      children: [
                        const Icon(Icons.event_outlined, size: 12, color: Color(0xFFA0A7A7)),
                        const SizedBox(width: 3),
                        Text(
                          DateFormat('dd/MM/yyyy').format(order.deliveryDate!),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFA0A7A7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
