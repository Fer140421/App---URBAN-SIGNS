class Quotation {
  const Quotation({
    required this.id,
    required this.ownerId,
    required this.clientName,
    required this.clientPhone,
    this.clientEmail,
    required this.projectTitle,
    required this.serviceType,
    required this.description,
    this.widthMeters = 1.0,
    this.heightMeters = 1.0,
    this.quantity = 1,
    this.unitPrice = 0.0,
    required this.totalAmount,
    this.status = 'pendiente',
    this.imageUrl,
    this.notes,
    this.latitude,
    this.longitude,
    this.deliveryAddress,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String ownerId;
  final String clientName;
  final String clientPhone;
  final String? clientEmail;
  final String projectTitle;
  final String serviceType;
  final String description;
  final double widthMeters;
  final double heightMeters;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final String status;
  final String? imageUrl;
  final String? notes;
  final double? latitude;
  final double? longitude;
  final String? deliveryAddress;
  final DateTime createdAt;
  final DateTime updatedAt;

  double get areaSquareMeters => (widthMeters * heightMeters) * quantity;
  bool get isApproved => status == 'aprobada';
  bool get isPending => status == 'pendiente';
  bool get isDraft => status == 'borrador';
  bool get isRejected => status == 'rechazada';

  Quotation copyWith({
    String? id,
    String? ownerId,
    String? clientName,
    String? clientPhone,
    String? clientEmail,
    String? projectTitle,
    String? serviceType,
    String? description,
    double? widthMeters,
    double? heightMeters,
    int? quantity,
    double? unitPrice,
    double? totalAmount,
    String? status,
    String? imageUrl,
    String? notes,
    double? latitude,
    double? longitude,
    String? deliveryAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Quotation(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      clientEmail: clientEmail ?? this.clientEmail,
      projectTitle: projectTitle ?? this.projectTitle,
      serviceType: serviceType ?? this.serviceType,
      description: description ?? this.description,
      widthMeters: widthMeters ?? this.widthMeters,
      heightMeters: heightMeters ?? this.heightMeters,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      notes: notes ?? this.notes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Quotation.fromMap(Map<String, dynamic> map) {
    return Quotation(
      id: map['id'] as String,
      ownerId: map['owner_id'] as String,
      clientName: map['client_name'] as String? ?? 'Cliente sin nombre',
      clientPhone: map['client_phone'] as String? ?? '',
      clientEmail: map['client_email'] as String?,
      projectTitle: map['project_title'] as String? ?? 'Proyecto publicitario',
      serviceType: map['service_type'] as String? ?? 'Otro',
      description: map['description'] as String? ?? '',
      widthMeters: (map['width_meters'] as num?)?.toDouble() ?? 1.0,
      heightMeters: (map['height_meters'] as num?)?.toDouble() ?? 1.0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (map['unit_price'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String? ?? 'pendiente',
      imageUrl: map['image_url'] as String?,
      notes: map['notes'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      deliveryAddress: map['delivery_address'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toDatabaseMap({required String owner}) {
    return {
      'owner_id': owner,
      'client_name': clientName.trim(),
      'client_phone': clientPhone.trim(),
      'client_email': clientEmail?.trim().isEmpty == true ? null : clientEmail?.trim(),
      'project_title': projectTitle.trim(),
      'service_type': serviceType,
      'description': description.trim(),
      'width_meters': widthMeters,
      'height_meters': heightMeters,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_amount': totalAmount,
      'status': status,
      'image_url': imageUrl,
      'notes': notes?.trim().isEmpty == true ? null : notes?.trim(),
      'latitude': latitude,
      'longitude': longitude,
      'delivery_address': deliveryAddress?.trim().isEmpty == true ? null : deliveryAddress?.trim(),
    };
  }
}
