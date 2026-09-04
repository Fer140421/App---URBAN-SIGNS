import '../models/order.dart';
import 'order_repository.dart';

class DemoOrderRepository implements OrderRepository {
  final List<Order> _items = [
    Order(
      id: 'order-demo-1',
      quotationId: 'quote-demo-1',
      orderNumber: 'PED-2026-001',
      ownerId: 'demo-user',
      clientName: 'Restaurante & Grill El Fogón',
      clientPhone: '+591 71234567',
      projectTitle: 'Letrero Frontal en Acrílico Backlight LED',
      serviceType: 'Letreros en Acrílico',
      specifications: '3.20m x 1.00m, caja aluminio, frontal acrílico opalino 3mm, iluminación LED IP67 12V con fuente hermética.',
      totalAmount: 2450.00,
      advancePayment: 1500.00,
      status: 'en_produccion',
      deliveryDate: DateTime.now().add(const Duration(days: 2)),
      deliveryAddress: 'Av. Las Américas #450, Tarija',
      latitude: -21.5332,
      longitude: -64.7340,
      imageUrl: 'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=800&q=80',
      notes: 'Anticipo recibido del 60%. Montaje programado para viernes por la mañana.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    Order(
      id: 'order-demo-2',
      quotationId: null,
      orderNumber: 'PED-2026-002',
      ownerId: 'demo-user',
      clientName: 'Gimnasio PowerFit 360',
      clientPhone: '+591 72345678',
      projectTitle: 'Letras Corpóreas en Polyfan con Neón LED Flexible',
      serviceType: 'Letras Corpóreas / Neón LED',
      specifications: 'Logo "POWERFIT" de 2.00m x 0.60m en polyfan de 30mm pintado negro mate con silueta en neón LED amarillo/naranja.',
      totalAmount: 1850.00,
      advancePayment: 1850.00,
      status: 'en_diseno',
      deliveryDate: DateTime.now().add(const Duration(days: 4)),
      deliveryAddress: 'Calle Ingavi #890',
      latitude: -21.5310,
      longitude: -64.7290,
      imageUrl: 'https://images.unsplash.com/photo-1550684848-fac1c5b4e853?w=800&q=80',
      notes: 'Pagado al 100%. Vectorizando tipografía para corte CNC.',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Order(
      id: 'order-demo-3',
      quotationId: null,
      orderNumber: 'PED-2026-003',
      ownerId: 'demo-user',
      clientName: 'Constructora Guadalquivir SRL',
      clientPhone: '+591 73456789',
      projectTitle: 'Letreros de Obra y Vallas de Seguridad',
      serviceType: 'Banners y Gigantografías',
      specifications: '4 Vallas de lona microperforada mesh para viento de 4x2 metros con ojalillos cada 30cm y bastidores reforzados.',
      totalAmount: 3100.00,
      advancePayment: 2000.00,
      status: 'listo_para_entrega',
      deliveryDate: DateTime.now().add(const Duration(days: 1)),
      deliveryAddress: 'Edificio Residencial Las Palmas, Av. Integración',
      latitude: -21.5420,
      longitude: -64.7380,
      imageUrl: 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=800&q=80',
      notes: 'Listo en almacén. El cliente retira o solicita chofer.',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    Order(
      id: 'order-demo-4',
      quotationId: null,
      orderNumber: 'PED-2026-004',
      ownerId: 'demo-user',
      clientName: 'Boutique Glamour Tarija',
      clientPhone: '+591 74567890',
      projectTitle: 'Ploteo de Vidrieras en Vinil Esmerilado Decorativo',
      serviceType: 'Rotulación y Vinilos',
      specifications: 'Vinil arenado esmerilado con corte calado de patrones geométricos en 3 paños de vidrio de 2.20x1.50m.',
      totalAmount: 950.00,
      advancePayment: 950.00,
      status: 'instalado_entregado',
      deliveryDate: DateTime.now().subtract(const Duration(days: 2)),
      deliveryAddress: 'Peatonal 15 de Abril #234',
      latitude: -21.5348,
      longitude: -64.7305,
      imageUrl: 'https://images.unsplash.com/photo-1513151233558-d860c5398176?w=800&q=80',
      notes: 'Instalación terminada con conformidad y firma del cliente.',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Future<List<Order>> listOrders() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final copy = [..._items]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return copy;
  }

  @override
  Future<Order> createOrder(Order order) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    final count = _items.length + 1;
    final orderNum = order.orderNumber.isEmpty || order.orderNumber == 'PED-000'
        ? 'PED-${now.year}-${count.toString().padLeft(3, '0')}'
        : order.orderNumber;

    final created = order.copyWith(
      id: 'order-${now.microsecondsSinceEpoch}',
      orderNumber: orderNum,
      ownerId: 'demo-user',
      createdAt: now,
      updatedAt: now,
    );
    _items.insert(0, created);
    return created;
  }

  @override
  Future<Order> updateOrder(Order order) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final index = _items.indexWhere((o) => o.id == order.id);
    if (index < 0) throw StateError('Pedido no encontrado');
    final updated = order.copyWith(updatedAt: DateTime.now());
    _items[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteOrder(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _items.removeWhere((o) => o.id == id);
  }

  @override
  Future<Order> updateStatus(String id, String newStatus) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final index = _items.indexWhere((o) => o.id == id);
    if (index < 0) throw StateError('Pedido no encontrado');
    final updated = _items[index].copyWith(status: newStatus, updatedAt: DateTime.now());
    _items[index] = updated;
    return updated;
  }

  @override
  Future<Order> registerPayment(String id, double newAdvancePayment) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final index = _items.indexWhere((o) => o.id == id);
    if (index < 0) throw StateError('Pedido no encontrado');
    final updated = _items[index].copyWith(advancePayment: newAdvancePayment, updatedAt: DateTime.now());
    _items[index] = updated;
    return updated;
  }
}
