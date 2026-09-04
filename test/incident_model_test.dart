import 'package:flutter_test/flutter_test.dart';
import 'package:georescue_360/models/order.dart';
import 'package:georescue_360/models/quotation.dart';

void main() {
  group('Modelos Grafik 360', () {
    test('Quotation model calculates area and parses map correctly', () {
      final quote = Quotation.fromMap({
        'id': 'quote-1',
        'owner_id': 'user-1',
        'client_name': 'Restaurante Roma',
        'client_phone': '71234567',
        'project_title': 'Letrero Acrílico',
        'service_type': 'Letreros en Acrílico',
        'description': 'Letrero con iluminación LED',
        'width_meters': 3.0,
        'height_meters': 1.5,
        'quantity': 2,
        'unit_price': 1200.0,
        'total_amount': 2400.0,
        'status': 'pendiente',
        'created_at': '2026-08-30T10:00:00.000Z',
        'updated_at': '2026-08-30T10:00:00.000Z',
      });

      expect(quote.areaSquareMeters, 9.0); // 3 * 1.5 * 2
      expect(quote.isPending, isTrue);
      expect(quote.isApproved, isFalse);
      expect(quote.totalAmount, 2400.0);
    });

    test('Order model calculates balance and payment completion', () {
      final order = Order.fromMap({
        'id': 'order-1',
        'owner_id': 'user-1',
        'order_number': 'PED-2026-001',
        'client_name': 'Cliente Demo',
        'client_phone': '71234567',
        'project_title': 'Stand Expo',
        'service_type': 'Stands Publicitarios',
        'specifications': 'Stand modular 3x3',
        'total_amount': 4000.0,
        'advance_payment': 2500.0,
        'status': 'en_produccion',
        'created_at': '2026-08-30T10:00:00.000Z',
        'updated_at': '2026-08-30T10:00:00.000Z',
      });

      expect(order.balanceDue, 1500.0);
      expect(order.isPaidInFull, isFalse);
      expect(order.isInProduction, isTrue);

      final paidOrder = order.copyWith(advancePayment: 4000.0);
      expect(paidOrder.balanceDue, 0.0);
      expect(paidOrder.isPaidInFull, isTrue);
    });
  });
}
