import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/quotations_controller.dart';
import '../../core/utils/app_constants.dart';
import '../../models/quotation.dart';
import '../../services/image_service.dart';
import '../../services/location_service.dart';

class QuotationFormScreen extends StatefulWidget {
  const QuotationFormScreen({super.key, this.initial});

  final Quotation? initial;

  @override
  State<QuotationFormScreen> createState() => _QuotationFormScreenState();
}

class _QuotationFormScreenState extends State<QuotationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _clientName;
  late final TextEditingController _clientPhone;
  late final TextEditingController _clientEmail;
  late final TextEditingController _projectTitle;
  late final TextEditingController _description;
  late final TextEditingController _width;
  late final TextEditingController _height;
  late final TextEditingController _quantity;
  late final TextEditingController _unitPrice;
  late final TextEditingController _totalAmount;
  late final TextEditingController _notes;
  late final TextEditingController _deliveryAddress;

  late String _serviceType;
  late String _status;
  LatLng? _point;
  XFile? _pickedImage;
  bool _saving = false;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    final item = widget.initial;
    _clientName = TextEditingController(text: item?.clientName ?? '');
    _clientPhone = TextEditingController(text: item?.clientPhone ?? '');
    _clientEmail = TextEditingController(text: item?.clientEmail ?? '');
    _projectTitle = TextEditingController(text: item?.projectTitle ?? '');
    _description = TextEditingController(text: item?.description ?? '');
    _width = TextEditingController(text: (item?.widthMeters ?? 1.0).toString());
    _height = TextEditingController(text: (item?.heightMeters ?? 1.0).toString());
    _quantity = TextEditingController(text: (item?.quantity ?? 1).toString());
    _unitPrice = TextEditingController(text: (item?.unitPrice ?? 0.0).toStringAsFixed(2));
    _totalAmount = TextEditingController(text: (item?.totalAmount ?? 0.0).toStringAsFixed(2));
    _notes = TextEditingController(text: item?.notes ?? '');
    _deliveryAddress = TextEditingController(text: item?.deliveryAddress ?? '');

    _serviceType = item?.serviceType ?? AppConstants.categories.first;
    _status = item?.status ?? 'pendiente';

    if (item?.latitude != null && item?.longitude != null) {
      _point = LatLng(item!.latitude!, item.longitude!);
    }
  }

  @override
  void dispose() {
    _clientName.dispose();
    _clientPhone.dispose();
    _clientEmail.dispose();
    _projectTitle.dispose();
    _description.dispose();
    _width.dispose();
    _height.dispose();
    _quantity.dispose();
    _unitPrice.dispose();
    _totalAmount.dispose();
    _notes.dispose();
    _deliveryAddress.dispose();
    super.dispose();
  }

  void _recalculateTotal() {
    final qty = int.tryParse(_quantity.text) ?? 1;
    final price = double.tryParse(_unitPrice.text) ?? 0.0;
    final total = qty * price;
    _totalAmount.text = total.toStringAsFixed(2);
  }

  Future<void> _useGps() async {
    setState(() => _locating = true);
    try {
      final position = await context.read<LocationService>().currentPosition();
      if (!mounted) return;
      setState(() => _point = LatLng(position.latitude, position.longitude));
    } catch (e) {
      if (mounted) _show('No se pudo obtener ubicación GPS: $e');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFF181C1D),
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined, color: Color(0xFFFFC400)),
              title: const Text('Tomar fotografía de referencia', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: Color(0xFFFFC400)),
              title: const Text('Elegir de galería / diseño digital', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    final service = context.read<ImageService>();
    final image = source == ImageSource.camera
        ? await service.pickCamera()
        : await service.pickGallery();
    if (image != null && mounted) setState(() => _pickedImage = image);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final app = context.read<AppController>();
    final controller = context.read<QuotationsController>();

    try {
      String? imageUrl = widget.initial?.imageUrl;
      if (_pickedImage != null && !app.demoMode) {
        imageUrl = await context.read<ImageService>().uploadToSupabase(_pickedImage!);
      }

      final now = DateTime.now();
      final owner = widget.initial?.ownerId ?? app.currentUserId ?? 'demo-user';
      final total = double.tryParse(_totalAmount.text) ?? 0.0;
      final unit = double.tryParse(_unitPrice.text) ?? 0.0;
      final w = double.tryParse(_width.text) ?? 1.0;
      final h = double.tryParse(_height.text) ?? 1.0;
      final q = int.tryParse(_quantity.text) ?? 1;

      final quotation = Quotation(
        id: widget.initial?.id ?? '',
        ownerId: owner,
        clientName: _clientName.text.trim(),
        clientPhone: _clientPhone.text.trim(),
        clientEmail: _clientEmail.text.trim().isEmpty ? null : _clientEmail.text.trim(),
        projectTitle: _projectTitle.text.trim(),
        serviceType: _serviceType,
        description: _description.text.trim(),
        widthMeters: w,
        heightMeters: h,
        quantity: q,
        unitPrice: unit,
        totalAmount: total > 0 ? total : (q * unit),
        status: _status,
        imageUrl: imageUrl,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        latitude: _point?.latitude,
        longitude: _point?.longitude,
        deliveryAddress: _deliveryAddress.text.trim().isEmpty ? null : _deliveryAddress.text.trim(),
        createdAt: widget.initial?.createdAt ?? now,
        updatedAt: now,
      );

      final saved = widget.initial == null
          ? await controller.create(quotation)
          : await controller.update(quotation);

      if (!mounted) return;
      _show(widget.initial == null ? 'Cotización registrada con éxito.' : 'Cotización actualizada.');
      context.pushReplacement('/quotations/${saved.id}');
    } catch (e) {
      if (mounted) _show('No se pudo guardar: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _show(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.initial != null;
    final point = _point ?? const LatLng(AppConstants.defaultLatitude, AppConstants.defaultLongitude);

    return Scaffold(
      backgroundColor: const Color(0xFF101313),
      appBar: AppBar(
        title: Text(editing ? 'Editar Cotización' : 'Nueva Cotización'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            // SECCIÓN 1: DATOS DEL CLIENTE
            _FormSectionCard(
              number: '01',
              title: 'Datos del Cliente',
              subtitle: 'Información de contacto para presupuestos.',
              children: [
                const _InputLabel(label: 'Nombre del Cliente o Empresa', required: true),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _clientName,
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                  decoration: const InputDecoration(
                    hintText: 'Ej. Restaurante El Fogón / Juan Pérez',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => (v ?? '').trim().length < 2 ? 'Ingresa el nombre del cliente.' : null,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _InputLabel(label: 'Teléfono / WhatsApp', required: true),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _clientPhone,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(color: Colors.white, fontSize: 13.5),
                            decoration: const InputDecoration(
                              hintText: '+591 71234567',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                            validator: (v) => (v ?? '').trim().length < 6 ? 'Ingresa teléfono.' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _InputLabel(label: 'Correo Electrónico'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _clientEmail,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white, fontSize: 13.5),
                            decoration: const InputDecoration(
                              hintText: 'cliente@empresa.com',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // SECCIÓN 2: TRABAJO Y MEDIDAS
            _FormSectionCard(
              number: '02',
              title: 'Producto y Dimensiones',
              subtitle: 'Tipo de servicio publicitario, medidas y materiales.',
              children: [
                const _InputLabel(label: 'Título o Nombre del Trabajo', required: true),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _projectTitle,
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                  decoration: const InputDecoration(
                    hintText: 'Ej. Letrero en Acrílico Backlight LED, Stand 3x3',
                    prefixIcon: Icon(Icons.title_outlined),
                  ),
                  validator: (v) => (v ?? '').trim().length < 3 ? 'Ingresa un título descriptivo.' : null,
                ),
                const SizedBox(height: 14),
                const _InputLabel(label: 'Categoría de Servicio', required: true),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _serviceType,
                  dropdownColor: const Color(0xFF181C1D),
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.category_outlined)),
                  items: AppConstants.categories
                      .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                      .toList(),
                  onChanged: (val) => setState(() => _serviceType = val ?? _serviceType),
                ),
                const SizedBox(height: 14),
                const _InputLabel(label: 'Detalles y Especificaciones Técnicas', required: true),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _description,
                  minLines: 3,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                  decoration: const InputDecoration(
                    hintText: 'Materiales (acrílico 3mm, lona 13oz, vinil), estructura de fierro, iluminación LED, acabado...',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                  validator: (v) => (v ?? '').trim().length < 5 ? 'Describe el trabajo.' : null,
                ),
                const SizedBox(height: 16),

                // Dimensiones
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _InputLabel(label: 'Ancho (m)'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _width,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                            decoration: const InputDecoration(
                              suffixText: 'm',
                              suffixStyle: TextStyle(color: Color(0xFFFFC400), fontWeight: FontWeight.bold),
                            ),
                            onChanged: (_) => setState(_recalculateTotal),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _InputLabel(label: 'Alto (m)'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _height,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                            decoration: const InputDecoration(
                              suffixText: 'm',
                              suffixStyle: TextStyle(color: Color(0xFFFFC400), fontWeight: FontWeight.bold),
                            ),
                            onChanged: (_) => setState(_recalculateTotal),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _InputLabel(label: 'Cantidad'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _quantity,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                            decoration: const InputDecoration(
                              suffixText: 'u',
                              suffixStyle: TextStyle(color: Color(0xFFFFC400), fontWeight: FontWeight.bold),
                            ),
                            onChanged: (_) => setState(_recalculateTotal),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Precios
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _InputLabel(label: 'Precio Unitario', required: true),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _unitPrice,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                            decoration: const InputDecoration(
                              prefixText: 'Bs. ',
                              prefixStyle: TextStyle(color: Color(0xFFFFC400), fontWeight: FontWeight.bold),
                            ),
                            onChanged: (_) => setState(_recalculateTotal),
                            validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0 ? 'Ingresa precio.' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _InputLabel(label: 'Total Calculado'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _totalAmount,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(color: Color(0xFFFFC400), fontWeight: FontWeight.w900, fontSize: 16),
                            decoration: const InputDecoration(
                              prefixText: 'Bs. ',
                              prefixStyle: TextStyle(color: Color(0xFFFFC400), fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _InputLabel(label: 'Estado'),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _status,
                            dropdownColor: const Color(0xFF181C1D),
                            style: const TextStyle(color: Colors.white, fontSize: 13.5),
                            decoration: const InputDecoration(),
                            items: AppConstants.quotationStatuses
                                .map((val) => DropdownMenuItem(value: val, child: Text(val.toUpperCase())))
                                .toList(),
                            onChanged: (val) => setState(() => _status = val ?? _status),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const _InputLabel(label: 'Condiciones de Entrega / Notas'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _notes,
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                  decoration: const InputDecoration(
                    hintText: 'Ej. Tiempo de entrega: 3 días hábiles. Anticipo del 50%...',
                    prefixIcon: Icon(Icons.info_outline),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // SECCIÓN 3: INSTALACIÓN Y FOTOS
            _FormSectionCard(
              number: '03',
              title: 'Lugar de Montaje & Boceto',
              subtitle: 'Ubicación física y foto de referencia.',
              children: [
                const _InputLabel(label: 'Dirección de Entrega / Montaje'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _deliveryAddress,
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                  decoration: const InputDecoration(
                    hintText: 'Ej. Calle Sucre #450, Barrio San Roque',
                    prefixIcon: Icon(Icons.place_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: _locating ? null : _useGps,
                    icon: _locating
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.my_location, size: 18),
                    label: const Text('Capturar Ubicación Actual (GPS)'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF262B2C),
                      foregroundColor: const Color(0xFFFFC400),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    height: 200,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: point,
                        initialZoom: _point == null ? 13 : 16,
                        onTap: (_, tapped) => setState(() => _point = tapped),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: AppConstants.osmUrl,
                          userAgentPackageName: 'bo.edu.uajms.georescue360',
                        ),
                        if (_point != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _point!,
                                width: 44,
                                height: 44,
                                child: const Icon(Icons.location_on, color: Colors.redAccent, size: 40),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: const Text('Adjuntar Boceto / Arte Visual'),
                  ),
                ),
                if (_pickedImage != null) ...[
                  const SizedBox(height: 10),
                  FutureBuilder<Uint8List>(
                    future: _pickedImage!.readAsBytes(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const LinearProgressIndicator();
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.memory(snapshot.data!, fit: BoxFit.cover),
                        ),
                      );
                    },
                  ),
                ] else if (widget.initial?.imageUrl != null && widget.initial!.imageUrl!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(widget.initial!.imageUrl!, fit: BoxFit.cover),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),

            // BOTÓN PRINCIPAL DE GUARDAR
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Icon(Icons.check, size: 20),
                label: Text(editing ? 'GUARDAR CAMBIOS' : 'REGISTRAR COTIZACIÓN'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC400),
                  foregroundColor: Colors.black,
                  textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, letterSpacing: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormSectionCard extends StatelessWidget {
  const _FormSectionCard({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String number;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF181C1D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF292E30), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Color(0xFFA0A7A7), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _InputLabel extends StatelessWidget {
  const _InputLabel({required this.label, this.required = false});
  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFD2D7D7),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (required)
          const Text(
            ' *',
            style: TextStyle(color: Color(0xFFFFC400), fontWeight: FontWeight.bold),
          ),
      ],
    );
  }
}
