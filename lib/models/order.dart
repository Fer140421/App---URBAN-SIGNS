class Order {
  const Order({
    required this.id,
    required this.ownerId,
    this.quotationId,
    required this.orderNumber,
    required this.clientName,
    required this.clientPhone,
    required this.projectTitle,
    required this.serviceType,
    required this.specifications,
    required this.totalAmount,
    this.advancePayment = 0.0,
    this.status = 'en_diseno',
    this.deliveryDate,
    this.imageUrl,
    this.deliveryAddress,
    this.latitude,
    this.longitude,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String ownerId;
  final String? quotationId;
  final String orderNumber;
  final String clientName;
  final String clientPhone;
  final String projectTitle;
  final String serviceType;
  final String specifications;
  final double totalAmount;
  final double advancePayment;
  final String status;
  final DateTime? deliveryDate;
  final String? imageUrl;
  final String? deliveryAddress;
  final double? latitude;
  final double? longitude;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  double get balanceDue => (totalAmount - advancePayment).clamp(0.0, double.infinity);
  bool get isPaidInFull => advancePayment >= totalAmount && totalAmount > 0;
  bool get isCompleted => status == 'instalado_entregado';
  bool get isInProduction => status == 'en_produccion';
  bool get isReady => status == 'listo_para_entrega';

  Order copyWith({
    String? id,
    String? ownerId,
    String? quotationId,
    String? orderNumber,
    String? clientName,
    String? clientPhone,
    String? projectTitle,
    String? serviceType,
    String? specifications,
    double? totalAmount,
    double? advancePayment,
    String? status,
    DateTime? deliveryDate,
    String? imageUrl,
    String? deliveryAddress,
    double? latitude,
    double? longitude,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      quotationId: quotationId ?? this.quotationId,
      orderNumber: orderNumber ?? this.orderNumber,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      projectTitle: projectTitle ?? this.projectTitle,
      serviceType: serviceType ?? this.serviceType,
      specifications: specifications ?? this.specifications,
      totalAmount: totalAmount ?? this.totalAmount,
      advancePayment: advancePayment ?? this.advancePayment,
      status: status ?? this.status,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      imageUrl: imageUrl ?? this.imageUrl,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as String,
      ownerId: map['owner_id'] as String,
      quotationId: map['quotation_id'] as String?,
      orderNumber: map['order_number'] as String? ?? 'PED-000',
      clientName: map['client_name'] as String? ?? 'Cliente',
      clientPhone: map['client_phone'] as String? ?? '',
      projectTitle: map['project_title'] as String? ?? 'Trabajo publicitario',
      serviceType: map['service_type'] as String? ?? 'Otro',
      specifications: map['specifications'] as String? ?? '',
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0.0,
      advancePayment: (map['advance_payment'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String? ?? 'en_diseno',
      deliveryDate: map['delivery_date'] != null ? DateTime.tryParse(map['delivery_date'] as String) : null,
      imageUrl: map['image_url'] as String?,
      deliveryAddress: map['delivery_address'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toDatabaseMap({required String owner}) {
    return {
      'owner_id': owner,
      'quotation_id': quotationId,
      'order_number': orderNumber,
      'client_name': clientName.trim(),
      'client_phone': clientPhone.trim(),
      'project_title': projectTitle.trim(),
      'service_type': serviceType,
      'specifications': specifications.trim(),
      'total_amount': totalAmount,
      'advance_payment': advancePayment,
      'status': status,
      'delivery_date': deliveryDate?.toIso8601String(),
      'image_url': imageUrl,
      'delivery_address': deliveryAddress?.trim().isEmpty == true ? null : deliveryAddress?.trim(),
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes?.trim().isEmpty == true ? null : notes?.trim(),
    };
  }
}
