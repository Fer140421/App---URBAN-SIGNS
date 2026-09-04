import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/orders_controller.dart';
import '../../core/utils/app_constants.dart';
import '../../models/order.dart';
import '../../services/image_service.dart';
import '../../services/location_service.dart';

class OrderFormScreen extends StatefulWidget {
  const OrderFormScreen({super.key, this.initial});

  final Order? initial;

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _clientName;
  late final TextEditingController _clientPhone;
  late final TextEditingController _projectTitle;
  late final TextEditingController _specifications;
  late final TextEditingController _totalAmount;
  late final TextEditingController _advancePayment;
  late final TextEditingController _notes;
  late final TextEditingController _deliveryAddress;

  late String _serviceType;
  late String _status;
  DateTime? _deliveryDate;
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
    _projectTitle = TextEditingController(text: item?.projectTitle ?? '');
    _specifications = TextEditingController(text: item?.specifications ?? '');
    _totalAmount = TextEditingController(text: (item?.totalAmount ?? 0.0).toStringAsFixed(2));
    _advancePayment = TextEditingController(text: (item?.advancePayment ?? 0.0).toStringAsFixed(2));
    _notes = TextEditingController(text: item?.notes ?? '');
    _deliveryAddress = TextEditingController(text: item?.deliveryAddress ?? '');

    _serviceType = item?.serviceType ?? AppConstants.categories.first;
    _status = item?.status ?? 'en_produccion';
    _deliveryDate = item?.deliveryDate ?? DateTime.now().add(const Duration(days: 3));

    if (item?.latitude != null && item?.longitude != null) {
      _point = LatLng(item!.latitude!, item.longitude!);
    }
  }

  @override
  void dispose() {
    _clientName.dispose();
    _clientPhone.dispose();
    _projectTitle.dispose();
    _specifications.dispose();
    _totalAmount.dispose();
    _advancePayment.dispose();
    _notes.dispose();
    _deliveryAddress.dispose();
    super.dispose();
  }

  Future<void> _useGps() async {
    setState(() => _locating = true);
    try {
      final position = await context.read<LocationService>().currentPosition();
      if (!mounted) return;
      setState(() => _point = LatLng(position.latitude, position.longitude));
    } catch (e) {
      if (mounted) _show('No se pudo capturar GPS: $e');
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
              title: const Text('Tomar foto del trabajo / instalación', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: Color(0xFFFFC400)),
              title: const Text('Elegir de galería / arte final', style: TextStyle(color: Colors.white)),
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
    final controller = context.read<OrdersController>();

    try {
      String? imageUrl = widget.initial?.imageUrl;
      if (_pickedImage != null && !app.demoMode) {
        imageUrl = await context.read<ImageService>().uploadToSupabase(_pickedImage!);
      }

      final now = DateTime.now();
      final owner = widget.initial?.ownerId ?? app.currentUserId ?? 'demo-user';
      final total = double.tryParse(_totalAmount.text) ?? 0.0;
      final advance = double.tryParse(_advancePayment.text) ?? 0.0;

      final order = Order(
        id: widget.initial?.id ?? '',
        quotationId: widget.initial?.quotationId,
        orderNumber: widget.initial?.orderNumber ?? '',
        ownerId: owner,
        clientName: _clientName.text.trim(),
        clientPhone: _clientPhone.text.trim(),
        projectTitle: _projectTitle.text.trim(),
        serviceType: _serviceType,
        specifications: _specifications.text.trim(),
        totalAmount: total,
        advancePayment: advance,
        status: _status,
        deliveryDate: _deliveryDate,
        imageUrl: imageUrl,
        deliveryAddress: _deliveryAddress.text.trim().isEmpty ? null : _deliveryAddress.text.trim(),
        latitude: _point?.latitude,
        longitude: _point?.longitude,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        createdAt: widget.initial?.createdAt ?? now,
        updatedAt: now,
      );

      final saved = widget.initial == null
          ? await controller.create(order)
          : await controller.update(order);

      if (!mounted) return;
      _show(widget.initial == null ? 'Pedido registrado con éxito.' : 'Pedido actualizado.');
      context.pushReplacement('/orders/${saved.id}');
    } catch (e) {
      if (mounted) _show('No se pudo guardar el pedido: $e');
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
        title: Text(editing ? 'Editar Pedido' : 'Nuevo Pedido de Trabajo'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            // SECCIÓN 1: DATOS DEL TRABAJO Y CLIENTE
            _FormSectionCard(
              number: '01',
              title: 'Datos del Pedido y Cliente',
              subtitle: 'Identificación del trabajo a fabricar.',
              children: [
                const _InputLabel(label: 'Nombre del Cliente / Empresa', required: true),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _clientName,
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                  decoration: const InputDecoration(
                    hintText: 'Ej. Restaurante El Fogón / Carlos Mendoza',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => (v ?? '').trim().length < 2 ? 'Ingresa el nombre del cliente.' : null,
                ),
                const SizedBox(height: 14),
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
                  validator: (v) => (v ?? '').trim().length < 6 ? 'Ingresa teléfono de contacto.' : null,
                ),
                const SizedBox(height: 14),
                const _InputLabel(label: 'Título del Trabajo', required: true),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _projectTitle,
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                  decoration: const InputDecoration(
                    hintText: 'Ej. Letrero Frontal Acrílico + Vinil',
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
                const _InputLabel(label: 'Especificaciones de Fabricación', required: true),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _specifications,
                  minLines: 3,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                  decoration: const InputDecoration(
                    hintText: 'Materiales, colores, tipo de LED, estructura metálica, corte CNC, requerimientos de armado...',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.construction_outlined),
                  ),
                  validator: (v) => (v ?? '').trim().length < 5 ? 'Ingresa especificaciones.' : null,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // SECCIÓN 2: CONTROL FINANCIERO Y PLAZO
            _FormSectionCard(
              number: '02',
              title: 'Cobros y Tiempos de Entrega',
              subtitle: 'Control de pagos recibidos y fecha de entrega.',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _InputLabel(label: 'Total Trabajo (Bs.)', required: true),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _totalAmount,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                            decoration: const InputDecoration(
                              prefixText: 'Bs. ',
                              prefixStyle: TextStyle(color: Color(0xFFFFC400), fontWeight: FontWeight.bold),
                            ),
                            validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0 ? 'Ingresa el total.' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _InputLabel(label: 'Anticipo Recibido (Bs.)'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _advancePayment,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(color: Color(0xFFFFC400), fontWeight: FontWeight.w700),
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
                const _InputLabel(label: 'Etapa del Pedido en Taller'),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  dropdownColor: const Color(0xFF181C1D),
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.tune_outlined)),
                  items: AppConstants.orderStatuses
                      .map((val) => DropdownMenuItem(
                            value: val,
                            child: Text(val.replaceAll('_', ' ').toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => _status = val ?? _status),
                ),
                const SizedBox(height: 14),
                const _InputLabel(label: 'Fecha Comprometida de Entrega'),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2425),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2D3335)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_outlined, color: Color(0xFFFFC400), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _deliveryDate != null
                              ? DateFormat('dd/MM/yyyy (EEEE)', 'es').format(_deliveryDate!)
                              : 'Sin fecha asignada',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.5),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _deliveryDate ?? DateTime.now().add(const Duration(days: 3)),
                            firstDate: DateTime.now().subtract(const Duration(days: 30)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) setState(() => _deliveryDate = picked);
                        },
                        icon: const Icon(Icons.edit_calendar, size: 16),
                        label: const Text('Cambiar'),
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFFFFC400)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const _InputLabel(label: 'Notas Adicionales de Taller'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _notes,
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                  decoration: const InputDecoration(
                    hintText: 'Ej. Requiere andamio para instalación, cableado de 15 metros...',
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // SECCIÓN 3: UBICACIÓN Y EVIDENCIA
            _FormSectionCard(
              number: '03',
              title: 'Lugar de Entrega & Fotos',
              subtitle: 'Ubicación de montaje y evidencia de producción.',
              children: [
                const _InputLabel(label: 'Dirección de Entrega / Montaje'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _deliveryAddress,
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                  decoration: const InputDecoration(
                    hintText: 'Ej. Av. Las Américas #450',
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
                    label: const Text('Capturar GPS de Instalación'),
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
                    height: 180,
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
                    label: const Text('Adjuntar Arte Final / Foto de Montaje'),
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

            // BOTÓN DE GUARDAR
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Icon(Icons.check, size: 20),
                label: Text(editing ? 'GUARDAR CAMBIOS' : 'CREAR PEDIDO DE TRABAJO'),
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
