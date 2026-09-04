import 'package:flutter_test/flutter_test.dart';
import 'package:georescue_360/models/order.dart';
import 'package:georescue_360/models/quotation.dart';
import 'package:georescue_360/repositories/demo_order_repository.dart';
import 'package:georescue_360/repositories/demo_quotation_repository.dart';

void main() {
  group('Demo Repositories CRUD', () {
    test('DemoQuotationRepository supports full CRUD and status update', () async {
      final repo = DemoQuotationRepository();
      final initial = await repo.listQuotations();
      expect(initial.isNotEmpty, isTrue);

      final now = DateTime.now();
      final newQuote = Quotation(
        id: '',
        ownerId: 'demo-user',
        clientName: 'Nuevo Cliente',
        clientPhone: '71112233',
        projectTitle: 'Banner Gigante',
        serviceType: 'Banners y Gigantografías',
        description: 'Impresión lona 13oz',
        widthMeters: 2.0,
        heightMeters: 1.0,
        quantity: 1,
        unitPrice: 150.0,
        totalAmount: 150.0,
        status: 'pendiente',
        createdAt: now,
        updatedAt: now,
      );

      final created = await repo.createQuotation(newQuote);
      expect(created.id, isNotEmpty);
      expect((await repo.listQuotations()).length, initial.length + 1);

      final updated = await repo.updateStatus(created.id, 'aprobada');
      expect(updated.status, 'aprobada');

      await repo.deleteQuotation(created.id);
      expect((await repo.listQuotations()).length, initial.length);
    });

    test('DemoOrderRepository supports full CRUD and payment registration', () async {
      final repo = DemoOrderRepository();
      final initial = await repo.listOrders();
      expect(initial.isNotEmpty, isTrue);

      final now = DateTime.now();
      final newOrder = Order(
        id: '',
        orderNumber: 'PED-TEST',
        ownerId: 'demo-user',
        clientName: 'Cliente Test',
        clientPhone: '72223344',
        projectTitle: 'Letrero Neón',
        serviceType: 'Letras Corpóreas / Neón LED',
        specifications: 'Neón flexible amarillo',
        totalAmount: 1000.0,
        advancePayment: 500.0,
        status: 'en_produccion',
        createdAt: now,
        updatedAt: now,
      );

      final created = await repo.createOrder(newOrder);
      expect(created.id, isNotEmpty);
      expect((await repo.listOrders()).length, initial.length + 1);

      final paid = await repo.registerPayment(created.id, 1000.0);
      expect(paid.advancePayment, 1000.0);
      expect(paid.balanceDue, 0.0);

      await repo.deleteOrder(created.id);
      expect((await repo.listOrders()).length, initial.length);
    });
  });
}
