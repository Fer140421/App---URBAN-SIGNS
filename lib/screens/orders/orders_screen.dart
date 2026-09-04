import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/orders_controller.dart';
import '../../models/order.dart';
import '../../widgets/order_card.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _search = TextEditingController();
  String _status = 'todos';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Order> _filtered(List<Order> source) {
    final query = _search.text.trim().toLowerCase();
    return source.where((item) {
      final matchesQuery = query.isEmpty ||
          item.orderNumber.toLowerCase().contains(query) ||
          item.clientName.toLowerCase().contains(query) ||
          item.projectTitle.toLowerCase().contains(query) ||
          item.serviceType.toLowerCase().contains(query) ||
          item.specifications.toLowerCase().contains(query);
      final matchesStatus = _status == 'todos' || item.status == _status;
      return matchesQuery && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OrdersController>();
    final app = context.watch<AppController>();
    final items = _filtered(controller.items);

    return Scaffold(
      backgroundColor: const Color(0xFF101313),
      appBar: AppBar(
        title: const Text('Pedidos de Producción'),
        actions: [
          IconButton(
            onPressed: controller.load,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar lista',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/orders/new'),
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Nuevo Pedido'),
        backgroundColor: const Color(0xFFFFC400),
        foregroundColor: Colors.black,
      ),
      body: RefreshIndicator(
        color: const Color(0xFFFFC400),
        onRefresh: controller.load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            TextField(
              controller: _search,
              style: const TextStyle(color: Colors.white, fontSize: 13.5),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Buscar por # pedido, cliente, título o producto...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFFFFC400)),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _search.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close, color: Colors.grey),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Todos (${controller.total})',
                    selected: _status == 'todos',
                    onTap: () => setState(() => _status = 'todos'),
                  ),
                  _FilterChip(
                    label: 'En Diseño (${controller.inDesignCount})',
                    selected: _status == 'en_diseno',
                    onTap: () => setState(() => _status = 'en_diseno'),
                  ),
                  _FilterChip(
                    label: 'En Producción (${controller.inProductionCount})',
                    selected: _status == 'en_produccion',
                    onTap: () => setState(() => _status = 'en_produccion'),
                  ),
                  _FilterChip(
                    label: 'Listos p/ Entrega (${controller.readyCount})',
                    selected: _status == 'listo_para_entrega',
                    onTap: () => setState(() => _status = 'listo_para_entrega'),
                  ),
                  _FilterChip(
                    label: 'Entregados (${controller.deliveredCount})',
                    selected: _status == 'instalado_entregado',
                    onTap: () => setState(() => _status = 'instalado_entregado'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (controller.loading && controller.items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator(color: Color(0xFFFFC400))),
              )
            else if (controller.error != null && controller.items.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(children: [
                    const Icon(Icons.error_outline, size: 42, color: Colors.redAccent),
                    const SizedBox(height: 8),
                    Text(controller.error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 12),
                    FilledButton.tonal(
                      onPressed: controller.load,
                      child: const Text('Reintentar'),
                    ),
                  ]),
                ),
              )
            else if (items.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(26),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.precision_manufacturing_outlined, size: 48, color: Color(0xFF5A6264)),
                        const SizedBox(height: 10),
                        const Text('No se encontraron pedidos con estos filtros.', style: TextStyle(color: Color(0xFFA0A7A7))),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () => context.push('/orders/new'),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Crear Pedido de Trabajo'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFFC400),
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: OrderCard(
                      order: item,
                      compact: app.compactCards,
                      onTap: () => context.push('/orders/${item.id}'),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: const Color(0xFFFFC400),
        backgroundColor: const Color(0xFF181C1D),
        side: BorderSide(
          color: selected ? const Color(0xFFFFC400) : const Color(0xFF2B3133),
          width: 1,
        ),
        labelStyle: TextStyle(
          color: selected ? Colors.black : const Color(0xFFA0A7A7),
          fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
          fontSize: 11.5,
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }
}
