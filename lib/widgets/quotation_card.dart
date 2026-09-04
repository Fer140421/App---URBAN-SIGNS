import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/quotation.dart';

class QuotationCard extends StatelessWidget {
  const QuotationCard({
    super.key,
    required this.quotation,
    required this.onTap,
    this.compact = false,
  });

  final Quotation quotation;
  final VoidCallback onTap;
  final bool compact;

  Color _statusColor() {
    return switch (quotation.status) {
      'aprobada' => const Color(0xFF00E676),
      'pendiente' => const Color(0xFFFFC400),
      'borrador' => const Color(0xFF90A4AE),
      'rechazada' => const Color(0xFFFF5252),
      _ => const Color(0xFFFFC400),
    };
  }

  String _statusLabel() {
    return switch (quotation.status) {
      'aprobada' => 'APROBADA',
      'pendiente' => 'PENDIENTE',
      'borrador' => 'BORRADOR',
      'rechazada' => 'RECHAZADA',
      _ => quotation.status.toUpperCase(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();
    final currency = NumberFormat.currency(symbol: 'Bs. ', decimalDigits: 2);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra vertical de estado
              Container(
                width: 5,
                height: 72,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fila 1: Título del Proyecto y Precio
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            quotation.projectTitle,
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
                          currency.format(quotation.totalAmount),
                          style: const TextStyle(
                            color: Color(0xFFFFC400),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    // Fila 2: Cliente
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 14, color: Color(0xFFA0A7A7)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            quotation.clientName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFD2D7D7),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Fila 3: Chips organizados (Categoría, Medidas, Estado)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _MiniBadge(
                          text: quotation.serviceType,
                          bg: const Color(0xFF262B2C),
                          fg: const Color(0xFFE0E5E5),
                        ),
                        _MiniBadge(
                          text: '${quotation.widthMeters.toStringAsFixed(2)}m × ${quotation.heightMeters.toStringAsFixed(2)}m (${quotation.quantity}u)',
                          bg: const Color(0xFF1F2933),
                          fg: const Color(0xFF90CAF9),
                          icon: Icons.aspect_ratio,
                        ),
                        _MiniBadge(
                          text: _statusLabel(),
                          bg: statusColor.withValues(alpha: 0.18),
                          fg: statusColor,
                          bold: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: Color(0xFF555B5C), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({
    required this.text,
    required this.bg,
    required this.fg,
    this.icon,
    this.bold = false,
  });

  final String text;
  final Color bg;
  final Color fg;
  final IconData? icon;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: fg),
            const SizedBox(width: 3),
          ],
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontSize: 10.5,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
