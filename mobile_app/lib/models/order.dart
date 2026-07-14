class Order {
  final int? id;
  final int customerId;
  final int measurementId;
  final String clothingType;
  final double price;
  final double amountPaid;
  final bool priority;
  final DateTime? deliveryDate;
  final String status;
  final String? notes;
  final String? imageUrl;
  final String? customerName;
  final String? customerPhone;
  final DateTime? createdAt;
  final String? orderNumber;

  Order({
    this.id,
    required this.customerId,
    required this.measurementId,
    required this.clothingType,
    required this.price,
    this.amountPaid = 0,
    this.priority = false,
    this.deliveryDate,
    required this.status,
    this.notes,
    this.imageUrl,
    this.customerName,
    this.customerPhone,
    this.createdAt,
    this.orderNumber,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerId: json['customer_id'],
      measurementId: json['measurement_id'],
      clothingType: json['clothing_type'],
      price: double.parse(json['price'].toString()),
      amountPaid: json['amount_paid'] != null ? double.parse(json['amount_paid'].toString()) : 0.0,
      priority: json['priority'] == 1 || json['priority'] == true,
      deliveryDate: json['delivery_date'] != null ? DateTime.parse(json['delivery_date']) : null,
      status: json['status'],
      notes: json['notes'],
      imageUrl: json['image_url'],
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      orderNumber: json['order_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'measurement_id': measurementId,
      'clothing_type': clothingType,
      'price': price,
      'amount_paid': amountPaid,
      'priority': priority ? 1 : 0,
      'delivery_date': deliveryDate?.toIso8601String(),
      'status': status,
      'notes': notes,
      'image_url': imageUrl,
    };
  }

  Order copyWith({
    int? id,
    int? customerId,
    int? measurementId,
    String? clothingType,
    double? price,
    double? amountPaid,
    bool? priority,
    DateTime? deliveryDate,
    String? status,
    String? notes,
    String? imageUrl,
    String? customerName,
    String? customerPhone,
    DateTime? createdAt,
    String? orderNumber,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      measurementId: measurementId ?? this.measurementId,
      clothingType: clothingType ?? this.clothingType,
      price: price ?? this.price,
      amountPaid: amountPaid ?? this.amountPaid,
      priority: priority ?? this.priority,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      createdAt: createdAt ?? this.createdAt,
      orderNumber: orderNumber ?? this.orderNumber,
    );
  }
}
