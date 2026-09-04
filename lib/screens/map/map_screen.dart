import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/orders_controller.dart';
import '../../controllers/quotations_controller.dart';
import '../../core/utils/app_constants.dart';
import '../../models/order.dart';
import '../../models/quotation.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _mapController = MapController();
  String _filter = 'todos'; // 'todos', 'pedidos', 'cotizaciones'

  @override
  Widget build(BuildContext context) {
    final quotesCtrl = context.watch<QuotationsController>();
    final ordersCtrl = context.watch<OrdersController>();

    final quotesWithCoords = quotesCtrl.items
        .where((q) => q.latitude != null && q.longitude != null)
        .toList();

    final ordersWithCoords = ordersCtrl.items
        .where((o) => o.latitude != null && o.longitude != null)
        .toList();

    final showQuotes = _filter == 'todos' || _filter == 'cotizaciones';
    final showOrders = _filter == 'todos' || _filter == 'pedidos';

    final totalPoints = (showQuotes ? quotesWithCoords.length : 0) +
        (showOrders ? ordersWithCoords.length : 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Instalaciones y Entregas'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _filter,
            onSelected: (value) => setState(() => _filter = value),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'todos', child: Text('Ver Todo')),
              PopupMenuItem(value: 'pedidos', child: Text('Solo Pedidos')),
              PopupMenuItem(value: 'cotizaciones', child: Text('Solo Cotizaciones')),
            ],
            icon: const Icon(Icons.filter_alt_outlined),
          ),
          IconButton(
            onPressed: () {
              quotesCtrl.load();
              ordersCtrl.load();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(AppConstants.defaultLatitude, AppConstants.defaultLongitude),
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: AppConstants.osmUrl,
                userAgentPackageName: 'bo.edu.uajms.georescue360',
              ),
              MarkerLayer(
                markers: [
                  if (showOrders)
                    ...ordersWithCoords.map(
                      (order) => Marker(
                        point: LatLng(order.latitude!, order.longitude!),
                        width: 52,
                        height: 52,
                        child: GestureDetector(
                          onTap: () => _showOrderPreview(context, order),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.shade700,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 6)],
                            ),
                            child: const Icon(Icons.precision_manufacturing, color: Colors.white, size: 24),
                          ),
                        ),
                      ),
                    ),
                  if (showQuotes)
                    ...quotesWithCoords.map(
                      (quote) => Marker(
                        point: LatLng(quote.latitude!, quote.longitude!),
                        width: 52,
                        height: 52,
                        child: GestureDetector(
                          onTap: () => _showQuotePreview(context, quote),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9100),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 6)],
                            ),
                            child: const Icon(Icons.request_quote, color: Colors.white, size: 24),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () => launchUrl(Uri.parse(AppConstants.osmCopyrightUrl)),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 14,
            right: 14,
            top: 14,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.layers_outlined),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '$totalPoints puntos georreferenciados · Filtro: ${_filter.toUpperCase()}',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showOrderPreview(BuildContext context, Order order) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(label: Text('PEDIDO ${order.orderNumber}')),
                const SizedBox(width: 8),
                Chip(label: Text(order.status.replaceAll('_', ' ').toUpperCase())),
              ],
            ),
            const SizedBox(height: 8),
            Text(order.projectTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text('Cliente: ${order.clientName} · ${order.clientPhone}'),
            if (order.deliveryAddress != null) ...[
              const SizedBox(height: 6),
              Text('📍 ${order.deliveryAddress!}', style: const TextStyle(color: Colors.grey)),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  context.push('/orders/${order.id}');
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Ver Detalle del Pedido'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showQuotePreview(BuildContext context, Quotation quote) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Chip(label: Text('COTIZACIÓN')),
                const SizedBox(width: 8),
                Chip(label: Text(quote.status.toUpperCase())),
              ],
            ),
            const SizedBox(height: 8),
            Text(quote.projectTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text('Cliente: ${quote.clientName} · Total: Bs. ${quote.totalAmount.toStringAsFixed(2)}'),
            if (quote.deliveryAddress != null) ...[
              const SizedBox(height: 6),
              Text('📍 ${quote.deliveryAddress!}', style: const TextStyle(color: Colors.grey)),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  context.push('/quotations/${quote.id}');
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Ver Detalle de la Cotización'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
