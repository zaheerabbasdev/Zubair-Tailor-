class Customer {
  final int? id;
  final String? uniqueId;
  final String name;
  final String phone;
  final String? address;

  Customer({this.id, this.uniqueId, required this.name, required this.phone, this.address});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      uniqueId: json['unique_id'],
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unique_id': uniqueId,
      'name': name,
      'phone': phone,
      'address': address,
    };
  }
}
