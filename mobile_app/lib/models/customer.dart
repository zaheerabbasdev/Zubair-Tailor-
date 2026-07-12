class Customer {
  final int? id;
  final String? uniqueId;
  final String name;
  final String phone;
  final String? address;
  final String? notes;

  Customer({this.id, this.uniqueId, required this.name, required this.phone, this.address, this.notes});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      uniqueId: json['unique_id'],
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unique_id': uniqueId,
      'name': name,
      'phone': phone,
      'address': address,
      'notes': notes,
    };
  }

  Customer copyWith({
    int? id,
    String? uniqueId,
    String? name,
    String? phone,
    String? address,
    String? notes,
  }) {
    return Customer(
      id: id ?? this.id,
      uniqueId: uniqueId ?? this.uniqueId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
    );
  }
}
