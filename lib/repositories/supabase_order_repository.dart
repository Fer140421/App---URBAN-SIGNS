import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/order.dart';
import 'order_repository.dart';

class SupabaseOrderRepository implements OrderRepository {
  SupabaseOrderRepository(this._client);

  final SupabaseClient _client;

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('Se requiere una sesión autenticada.');
    return id;
  }

  @override
  Future<List<Order>> listOrders() async {
    final data = await _client
        .from('orders')
        .select()
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((row) => Order.fromMap(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  @override
  Future<Order> createOrder(Order order) async {
    final payload = order.toDatabaseMap(owner: _userId);
    if (order.orderNumber.isEmpty || order.orderNumber == 'PED-000') {
      final countRes = await _client.from('orders').select('id');
      final count = (countRes as List).length + 1;
      payload['order_number'] = 'PED-${DateTime.now().year}-${count.toString().padLeft(3, '0')}';
    }

    final data = await _client
        .from('orders')
        .insert(payload)
        .select()
        .single();
    return Order.fromMap(Map<String, dynamic>.from(data));
  }

  @override
  Future<Order> updateOrder(Order order) async {
    final payload = order.toDatabaseMap(owner: order.ownerId)..remove('owner_id');
    final data = await _client
        .from('orders')
        .update(payload)
        .eq('id', order.id)
        .select()
        .single();
    return Order.fromMap(Map<String, dynamic>.from(data));
  }

  @override
  Future<void> deleteOrder(String id) async {
    await _client.from('orders').delete().eq('id', id);
  }

  @override
  Future<Order> updateStatus(String id, String newStatus) async {
    final data = await _client
        .from('orders')
        .update({'status': newStatus})
        .eq('id', id)
        .select()
        .single();
    return Order.fromMap(Map<String, dynamic>.from(data));
  }

  @override
  Future<Order> registerPayment(String id, double newAdvancePayment) async {
    final data = await _client
        .from('orders')
        .update({'advance_payment': newAdvancePayment})
        .eq('id', id)
        .select()
        .single();
    return Order.fromMap(Map<String, dynamic>.from(data));
  }
}
