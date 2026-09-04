import '../models/order.dart';

abstract class OrderRepository {
  Future<List<Order>> listOrders();
  Future<Order> createOrder(Order order);
  Future<Order> updateOrder(Order order);
  Future<void> deleteOrder(String id);
  Future<Order> updateStatus(String id, String newStatus);
  Future<Order> registerPayment(String id, double newAdvancePayment);
}
