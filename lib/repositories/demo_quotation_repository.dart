import '../models/quotation.dart';
import 'quotation_repository.dart';

class DemoQuotationRepository implements QuotationRepository {
  final List<Quotation> _items = [
    Quotation(
      id: 'quote-demo-1',
      ownerId: 'demo-user',
      clientName: 'Restaurante & Grill El Fogón',
      clientPhone: '+591 71234567',
      clientEmail: 'contacto@elfogon.com',
      projectTitle: 'Letrero Frontal en Acrílico Backlight LED',
      serviceType: 'Letreros en Acrílico',
      description: 'Letrero de 3.20m x 1.00m en caja metálica de aluminio, frontal acrílico opalino 3mm con vinil translúcido e iluminación interna de módulos LED IP67.',
      widthMeters: 3.20,
      heightMeters: 1.00,
      quantity: 1,
      unitPrice: 2450.00,
      totalAmount: 2450.00,
      status: 'aprobada',
      notes: 'Incluye estructura y montaje en fachada principal. Tiempo de fabricación: 4 días hábiles.',
      deliveryAddress: 'Av. Las Américas #450, Tarija',
      latitude: -21.5332,
      longitude: -64.7340,
      imageUrl: 'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=800&q=80',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Quotation(
      id: 'quote-demo-2',
      ownerId: 'demo-user',
      clientName: 'Banco Ganadero / Eventos Especiales',
      clientPhone: '+591 76543210',
      clientEmail: 'marketing@bancoganadero.bo',
      projectTitle: 'Stands Publicitarios Modulares & Roll-Ups',
      serviceType: 'Stands Publicitarios',
      description: 'Stand modular para feria de 3x3 metros: trasera en lona mate 13oz tensada con perfiles de aluminio, counter de atención en MDF ploteado y 2 roll-up banners 85x200cm.',
      widthMeters: 3.00,
      heightMeters: 2.40,
      quantity: 1,
      unitPrice: 4800.00,
      totalAmount: 4800.00,
      status: 'pendiente',
      notes: 'Requiere entrega y armado el día previo a la inauguración de la Expo.',
      deliveryAddress: 'Campo Ferial San Jacinto, Pabellón Internacional',
      latitude: -21.5580,
      longitude: -64.7210,
      imageUrl: 'https://images.unsplash.com/photo-1511578314322-379afb476865?w=800&q=80',
      createdAt: DateTime.now().subtract(const Duration(hours: 18)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 18)),
    ),
    Quotation(
      id: 'quote-demo-3',
      ownerId: 'demo-user',
      clientName: 'Farmacias San Elías',
      clientPhone: '+591 78901234',
      clientEmail: 'compras@farmaciaselias.bo',
      projectTitle: 'Banners Gigantografías Campaña de Salud',
      serviceType: 'Banners y Gigantografías',
      description: '6 Banners de lona frontlite 13oz alta definición a 1440 DPI, con bastidores de madera y ojalillos metálicos perimetrales de 2.00m x 1.20m.',
      widthMeters: 2.00,
      heightMeters: 1.20,
      quantity: 6,
      unitPrice: 180.00,
      totalAmount: 1080.00,
      status: 'pendiente',
      notes: 'Impresión en solvente de alta durabilidad para intemperie.',
      deliveryAddress: 'Sucursal Central, Calle Sucre y 15 de Abril',
      latitude: -21.5365,
      longitude: -64.7288,
      imageUrl: 'https://images.unsplash.com/photo-1542744094-3a31f272c490?w=800&q=80',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Quotation(
      id: 'quote-demo-4',
      ownerId: 'demo-user',
      clientName: 'Distribuidora Logística del Sur',
      clientPhone: '+591 70011223',
      clientEmail: 'flota@logisur.com',
      projectTitle: 'Rotulación Vehicular en Vinil Fundido y Microperforado',
      serviceType: 'Rotulación y Vinilos',
      description: 'Ploteo integral para furgoneta Toyota Hilux: vinil laminado con protección UV brillante y microperforado en luneta trasera.',
      widthMeters: 4.50,
      heightMeters: 1.50,
      quantity: 2,
      unitPrice: 1650.00,
      totalAmount: 3300.00,
      status: 'borrador',
      notes: 'Pendiente confirmación de los artes finales y logotipo vectorizado.',
      deliveryAddress: 'Parque Industrial Lote 14',
      latitude: -21.5210,
      longitude: -64.7450,
      imageUrl: 'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800&q=80',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  @override
  Future<List<Quotation>> listQuotations() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final copy = [..._items]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return copy;
  }

  @override
  Future<Quotation> createQuotation(Quotation quotation) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    final created = quotation.copyWith(
      id: 'quote-${now.microsecondsSinceEpoch}',
      ownerId: 'demo-user',
      createdAt: now,
      updatedAt: now,
    );
    _items.insert(0, created);
    return created;
  }

  @override
  Future<Quotation> updateQuotation(Quotation quotation) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final index = _items.indexWhere((q) => q.id == quotation.id);
    if (index < 0) throw StateError('Cotización no encontrada');
    final updated = quotation.copyWith(updatedAt: DateTime.now());
    _items[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteQuotation(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _items.removeWhere((q) => q.id == id);
  }

  @override
  Future<Quotation> updateStatus(String id, String newStatus) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final index = _items.indexWhere((q) => q.id == id);
    if (index < 0) throw StateError('Cotización no encontrada');
    final updated = _items[index].copyWith(status: newStatus, updatedAt: DateTime.now());
    _items[index] = updated;
    return updated;
  }
}
