import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/quotations_controller.dart';
import '../../core/utils/app_constants.dart';
import '../../models/quotation.dart';
import '../../widgets/quotation_card.dart';

class QuotationsScreen extends StatefulWidget {
  const QuotationsScreen({super.key});

  @override
  State<QuotationsScreen> createState() => _QuotationsScreenState();
}

class _QuotationsScreenState extends State<QuotationsScreen> {
  final _search = TextEditingController();
  String _status = 'todos';
  String _serviceFilter = 'todos';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Quotation> _filtered(List<Quotation> source) {
    final query = _search.text.trim().toLowerCase();
    return source.where((item) {
      final matchesQuery = query.isEmpty ||
          item.projectTitle.toLowerCase().contains(query) ||
          item.clientName.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query) ||
          item.serviceType.toLowerCase().contains(query);
      final matchesStatus = _status == 'todos' || item.status == _status;
      final matchesService = _serviceFilter == 'todos' || item.serviceType == _serviceFilter;
      return matchesQuery && matchesStatus && matchesService;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<QuotationsController>();
    final app = context.watch<AppController>();
    final items = _filtered(controller.items);

    return Scaffold(
      backgroundColor: const Color(0xFF101313),
      appBar: AppBar(
        title: const Text('Cotizaciones'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _serviceFilter,
            color: const Color(0xFF181C1D),
            onSelected: (value) => setState(() => _serviceFilter = value),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'todos', child: Text('Todos los servicios', style: TextStyle(color: Colors.white))),
              ...AppConstants.categories.map((c) => PopupMenuItem(value: c, child: Text(c, style: const TextStyle(color: Colors.white)))),
            ],
            icon: const Icon(Icons.filter_list_outlined, color: Color(0xFFFFC400)),
            tooltip: 'Filtrar por categoría',
          ),
          IconButton(
            onPressed: controller.load,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar lista',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/quotations/new'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Cotización'),
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
                hintText: 'Buscar por cliente, proyecto o producto...',
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
                    label: 'Todas (${controller.total})',
                    selected: _status == 'todos',
                    onTap: () => setState(() => _status = 'todos'),
                  ),
                  _FilterChip(
                    label: 'Pendientes (${controller.pendingCount})',
                    selected: _status == 'pendiente',
                    onTap: () => setState(() => _status = 'pendiente'),
                  ),
                  _FilterChip(
                    label: 'Aprobadas (${controller.approvedCount})',
                    selected: _status == 'aprobada',
                    onTap: () => setState(() => _status = 'aprobada'),
                  ),
                  _FilterChip(
                    label: 'Borradores (${controller.draftCount})',
                    selected: _status == 'borrador',
                    onTap: () => setState(() => _status = 'borrador'),
                  ),
                  _FilterChip(
                    label: 'Rechazadas (${controller.rejectedCount})',
                    selected: _status == 'rechazada',
                    onTap: () => setState(() => _status = 'rechazada'),
                  ),
                ],
              ),
            ),
            if (_serviceFilter != 'todos') ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Chip(
                    backgroundColor: const Color(0xFF1F2425),
                    label: Text('Categoría: $_serviceFilter', style: const TextStyle(color: Color(0xFFFFC400), fontWeight: FontWeight.w700, fontSize: 12)),
                    deleteIconColor: const Color(0xFFFFC400),
                    onDeleted: () => setState(() => _serviceFilter = 'todos'),
                  ),
                ],
              ),
            ],
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
                        const Icon(Icons.inventory_2_outlined, size: 48, color: Color(0xFF5A6264)),
                        const SizedBox(height: 10),
                        const Text('No se encontraron cotizaciones con estos filtros.', style: TextStyle(color: Color(0xFFA0A7A7))),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () => context.push('/quotations/new'),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Nueva Cotización'),
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
                    child: QuotationCard(
                      quotation: item,
                      compact: app.compactCards,
                      onTap: () => context.push('/quotations/${item.id}'),
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
