// File: order_model.dart
class Order {
  final String orderId;
  final DateTime date;
  final String status;
  final double totalAmount;
  final List<OrderItem> items;

  Order({
    required this.orderId,
    required this.date,
    required this.status,
    required this.totalAmount,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'date': date.toIso8601String(),
      'status': status,
      'totalAmount': totalAmount,
      'items': items.map((item) => item.toMap()).toList(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      orderId: map['orderId'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      status: map['status'] ?? 'In Progress',
      totalAmount: map['totalAmount']?.toDouble() ?? 0.0,
      items: map['items'] != null
          ? List<OrderItem>.from(map['items'].map((item) => OrderItem.fromMap(item)))
          : [],
    );
  }
}

class OrderItem {
  final String name;
  final double price;
  final String weight;
  final String time;
  final String image;
  final String? description;
  final String? voiceNote;

  OrderItem({
    required this.name,
    required this.price,
    required this.weight,
    required this.time,
    required this.image,
    this.description,
    this.voiceNote,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'weight': weight,
      'time': time,
      'image': image,
      'description': description,
      'voiceNote': voiceNote,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      name: map['name'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      weight: map['weight'] ?? '',
      time: map['time'] ?? '',
      image: map['image'] ?? 'assets/images/chicken.png',
      description: map['description'],
      voiceNote: map['voiceNote'],
    );
  }
}