class Measurement {
  final int? id;
  final int customerId;
  final String? shirtLength;
  final String? shirtWidth;
  final String? shoulder;
  final String? sleeve;
  final String? collar;
  final String? banType;
  final String? chest;
  final String? ghera;
  final String? pancha;
  final String? shalwarLength;
  final String? damanType;
  final bool frontPocket;
  final String? pocketType;
  final String? sleeveType;
  final bool cuff;
  final bool shalwarPocket;
  final bool ringButton;
  final bool doubleSilai;
  final bool chamakTar;
  final bool sadaPatti;
  final bool designButton;
  final String? notes;
  final String? createdAt;

  Measurement({
    this.id,
    required this.customerId,
    this.shirtLength,
    this.shirtWidth,
    this.shoulder,
    this.sleeve,
    this.collar,
    this.banType,
    this.chest,
    this.ghera,
    this.pancha,
    this.shalwarLength,
    this.damanType,
    this.frontPocket = false,
    this.pocketType,
    this.sleeveType,
    this.cuff = false,
    this.shalwarPocket = false,
    this.ringButton = false,
    this.doubleSilai = false,
    this.chamakTar = false,
    this.sadaPatti = false,
    this.designButton = false,
    this.notes,
    this.createdAt,
  });

  factory Measurement.fromJson(Map<String, dynamic> json) {
    return Measurement(
      id: json['id'],
      customerId: json['customer_id'],
      shirtLength: json['shirt_length']?.toString(),
      shirtWidth: json['shirt_width']?.toString(),
      shoulder: json['shoulder']?.toString(),
      sleeve: json['sleeve']?.toString(),
      collar: json['collar']?.toString(),
      banType: json['ban_type'],
      chest: json['chest']?.toString(),
      ghera: json['ghera']?.toString(),
      pancha: json['pancha']?.toString(),
      shalwarLength: json['shalwar_length']?.toString(),
      damanType: json['daman_type'],
      frontPocket: json['front_pocket'] == 1 || json['front_pocket'] == true,
      pocketType: json['pocket_type'],
      sleeveType: json['sleeve_type'],
      cuff: json['cuff'] == 1 || json['cuff'] == true,
      shalwarPocket: json['shalwar_pocket'] == 1 || json['shalwar_pocket'] == true,
      ringButton: json['ring_button'] == 1 || json['ring_button'] == true,
      doubleSilai: json['double_silai'] == 1 || json['double_silai'] == true,
      chamakTar: json['chamak_tar'] == 1 || json['chamak_tar'] == true,
      sadaPatti: json['sada_patti'] == 1 || json['sada_patti'] == true,
      designButton: json['design_button'] == 1 || json['design_button'] == true,
      notes: json['notes'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'shirt_length': shirtLength,
      'shirt_width': shirtWidth,
      'shoulder': shoulder,
      'sleeve': sleeve,
      'collar': collar,
      'ban_type': banType,
      'chest': chest,
      'ghera': ghera,
      'pancha': pancha,
      'shalwar_length': shalwarLength,
      'daman_type': damanType,
      'front_pocket': frontPocket ? 1 : 0,
      'pocket_type': pocketType,
      'sleeve_type': sleeveType,
      'cuff': cuff ? 1 : 0,
      'shalwar_pocket': shalwarPocket ? 1 : 0,
      'ring_button': ringButton ? 1 : 0,
      'double_silai': doubleSilai ? 1 : 0,
      'chamak_tar': chamakTar ? 1 : 0,
      'sada_patti': sadaPatti ? 1 : 0,
      'design_button': designButton ? 1 : 0,
      'notes': notes,
      'created_at': createdAt,
    };
  }

  Measurement copyWith({
    int? id,
    int? customerId,
    String? shirtLength,
    String? shirtWidth,
    String? shoulder,
    String? sleeve,
    String? collar,
    String? banType,
    String? chest,
    String? ghera,
    String? pancha,
    String? shalwarLength,
    String? damanType,
    bool? frontPocket,
    String? pocketType,
    String? sleeveType,
    bool? cuff,
    bool? shalwarPocket,
    bool? ringButton,
    bool? doubleSilai,
    bool? chamakTar,
    bool? sadaPatti,
    bool? designButton,
    String? notes,
    String? createdAt,
  }) {
    return Measurement(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      shirtLength: shirtLength ?? this.shirtLength,
      shirtWidth: shirtWidth ?? this.shirtWidth,
      shoulder: shoulder ?? this.shoulder,
      sleeve: sleeve ?? this.sleeve,
      collar: collar ?? this.collar,
      banType: banType ?? this.banType,
      chest: chest ?? this.chest,
      ghera: ghera ?? this.ghera,
      pancha: pancha ?? this.pancha,
      shalwarLength: shalwarLength ?? this.shalwarLength,
      damanType: damanType ?? this.damanType,
      frontPocket: frontPocket ?? this.frontPocket,
      pocketType: pocketType ?? this.pocketType,
      sleeveType: sleeveType ?? this.sleeveType,
      cuff: cuff ?? this.cuff,
      shalwarPocket: shalwarPocket ?? this.shalwarPocket,
      ringButton: ringButton ?? this.ringButton,
      doubleSilai: doubleSilai ?? this.doubleSilai,
      chamakTar: chamakTar ?? this.chamakTar,
      sadaPatti: sadaPatti ?? this.sadaPatti,
      designButton: designButton ?? this.designButton,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

