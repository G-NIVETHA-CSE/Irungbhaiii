import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'order_model.dart';

class OrderStorage {
  static const String _ordersKey = 'user_orders';

  // Save a new order to local storage
  static Future<void> saveOrder({
    required List<Map<String, dynamic>> items,
    required double totalAmount,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing orders or create empty list
    final ordersJson = prefs.getStringList(_ordersKey) ?? [];
    final orders = ordersJson
        .map((orderJson) => Order.fromMap(json.decode(orderJson)))
        .toList();

    // Create new order object using the Order model
    final newOrder = Order(
      orderId: 'ORD-${1000 + Random().nextInt(9000)}',
      date: DateTime.now(),
      status: 'In Progress',
      totalAmount: totalAmount,
      items: items.map((item) => OrderItem.fromMap(item)).toList(),
    );

    // Add new order to list
    orders.add(newOrder);

    // Convert orders back to JSON strings
    final updatedOrdersJson = orders.map((order) => json.encode(order.toMap())).toList();

    // Save to SharedPreferences
    await prefs.setStringList(_ordersKey, updatedOrdersJson);
  }

  // Get all orders from local storage
  static Future<List<Order>> getOrders() async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing orders or create empty list
    final ordersJson = prefs.getStringList(_ordersKey) ?? [];

    // Convert JSON strings to Order objects
    final orders = ordersJson
        .map((orderJson) => Order.fromMap(json.decode(orderJson)))
        .toList();

    // Sort by date, most recent first
    orders.sort((a, b) => b.date.compareTo(a.date));

    return orders;
  }

  // Clear all orders (for testing)
  static Future<void> clearOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ordersKey);
  }
}