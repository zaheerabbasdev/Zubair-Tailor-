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
      'front_pocket': frontPocket,
      'pocket_type': pocketType,
      'sleeve_type': sleeveType,
      'cuff': cuff,
      'shalwar_pocket': shalwarPocket,
      'ring_button': ringButton,
      'double_silai': doubleSilai,
      'chamak_tar': chamakTar,
      'sada_patti': sadaPatti,
      'design_button': designButton,
      'notes': notes,
      'created_at': createdAt,
    };
  }
}

