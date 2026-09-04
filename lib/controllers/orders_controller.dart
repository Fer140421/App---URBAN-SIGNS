import 'package:flutter/foundation.dart';

import '../models/order.dart';
import '../repositories/order_repository.dart';

class OrdersController extends ChangeNotifier {
  OrdersController(this._repository);

  final OrderRepository _repository;

  final List<Order> _items = [];
  bool _loading = false;
  String? _error;

  List<Order> get items => List.unmodifiable(_items);
  bool get loading => _loading;
  String? get error => _error;

  int get total => _items.length;
  int get inDesignCount => _items.where((o) => o.status == 'en_diseno').length;
  int get inProductionCount => _items.where((o) => o.status == 'en_produccion').length;
  int get readyCount => _items.where((o) => o.status == 'listo_para_entrega').length;
  int get deliveredCount => _items.where((o) => o.status == 'instalado_entregado').length;

  double get totalBilled => _items.fold(0.0, (sum, o) => sum + o.totalAmount);
  double get totalCollected => _items.fold(0.0, (sum, o) => sum + o.advancePayment);
  double get totalPendingBalance => _items.fold(0.0, (sum, o) => sum + o.balanceDue);

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _repository.listOrders();
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

  Future<Order> create(Order order) async {
    final created = await _repository.createOrder(order);
    _items.insert(0, created);
    notifyListeners();
    return created;
  }

  Future<Order> update(Order order) async {
    final updated = await _repository.updateOrder(order);
    final index = _items.indexWhere((item) => item.id == updated.id);
    if (index >= 0) _items[index] = updated;
    notifyListeners();
    return updated;
  }

  Future<void> delete(String id) async {
    await _repository.deleteOrder(id);
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<Order> updateStatus(String id, String newStatus) async {
    final updated = await _repository.updateStatus(id, newStatus);
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) _items[index] = updated;
    notifyListeners();
    return updated;
  }

  Future<Order> registerPayment(String id, double additionalAmount) async {
    final current = byId(id);
    if (current == null) throw StateError('Pedido no encontrado');
    final newTotalAdvance = current.advancePayment + additionalAmount;
    final updated = await _repository.registerPayment(id, newTotalAdvance);
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) _items[index] = updated;
    notifyListeners();
    return updated;
  }

  Order? byId(String id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }
}
