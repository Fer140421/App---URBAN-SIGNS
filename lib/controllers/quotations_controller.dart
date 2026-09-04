import 'package:flutter/foundation.dart';

import '../models/order.dart';
import '../models/quotation.dart';
import '../repositories/quotation_repository.dart';
import 'orders_controller.dart';

class QuotationsController extends ChangeNotifier {
  QuotationsController(this._repository);

  final QuotationRepository _repository;

  final List<Quotation> _items = [];
  bool _loading = false;
  String? _error;

  List<Quotation> get items => List.unmodifiable(_items);
  bool get loading => _loading;
  String? get error => _error;

  int get total => _items.length;
  int get pendingCount => _items.where((q) => q.status == 'pendiente').length;
  int get approvedCount => _items.where((q) => q.status == 'aprobada').length;
  int get draftCount => _items.where((q) => q.status == 'borrador').length;
  int get rejectedCount => _items.where((q) => q.status == 'rechazada').length;
  double get totalEstimatedAmount => _items.fold(0.0, (sum, q) => sum + q.totalAmount);

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _repository.listQuotations();
      _items
        ..clear()
        ..addAll(result);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Quotation> create(Quotation quotation) async {
    final created = await _repository.createQuotation(quotation);
    _items.insert(0, created);
    notifyListeners();
    return created;
  }

  Future<Quotation> update(Quotation quotation) async {
    final updated = await _repository.updateQuotation(quotation);
    final index = _items.indexWhere((item) => item.id == updated.id);
    if (index >= 0) _items[index] = updated;
    notifyListeners();
    return updated;
  }

  Future<void> delete(String id) async {
    await _repository.deleteQuotation(id);
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<Quotation> updateStatus(String id, String newStatus) async {
    final updated = await _repository.updateStatus(id, newStatus);
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) _items[index] = updated;
    notifyListeners();
    return updated;
  }

  /// Pasa una cotización a pedido de producción (Order), actualizando la cotización a 'aprobada'
  Future<Order> approveAndConvertToOrder({
    required Quotation quotation,
    required OrdersController ordersController,
    required double advancePayment,
    DateTime? deliveryDate,
    String? notes,
  }) async {
    // 1. Actualizar estado de cotización a 'aprobada'
    final updatedQuotation = await updateStatus(quotation.id, 'aprobada');

    // 2. Crear pedido vinculado
    final now = DateTime.now();
    final newOrder = Order(
      id: '',
      quotationId: updatedQuotation.id,
      orderNumber: '',
      ownerId: updatedQuotation.ownerId,
      clientName: updatedQuotation.clientName,
      clientPhone: updatedQuotation.clientPhone,
      projectTitle: updatedQuotation.projectTitle,
      serviceType: updatedQuotation.serviceType,
      specifications: '${updatedQuotation.description}\nDimensiones: ${updatedQuotation.widthMeters.toStringAsFixed(2)}m x ${updatedQuotation.heightMeters.toStringAsFixed(2)}m (${updatedQuotation.quantity} unid.)',
      totalAmount: updatedQuotation.totalAmount,
      advancePayment: advancePayment,
      status: 'en_produccion',
      deliveryDate: deliveryDate ?? now.add(const Duration(days: 3)),
      deliveryAddress: updatedQuotation.deliveryAddress,
      latitude: updatedQuotation.latitude,
      longitude: updatedQuotation.longitude,
      imageUrl: updatedQuotation.imageUrl,
      notes: notes ?? updatedQuotation.notes,
      createdAt: now,
      updatedAt: now,
    );

    final createdOrder = await ordersController.create(newOrder);
    return createdOrder;
  }

  Quotation? byId(String id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }
}
