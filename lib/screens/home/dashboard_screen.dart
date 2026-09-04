import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/orders_controller.dart';
import '../../controllers/quotations_controller.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/order_card.dart';
import '../../widgets/quotation_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _requestedLoad = false;
  int _selectedTab = 0; // 0: Pedidos en Taller, 1: Cotizaciones Pendientes

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_requestedLoad) {
      _requestedLoad = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<QuotationsController>().load();
          context.read<OrdersController>().load();
        }
      });
    }
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      context.read<QuotationsController>().load(),
      context.read<OrdersController>().load(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final quotations = context.watch<QuotationsController>();
    final orders = context.watch<OrdersController>();
    final currency = NumberFormat.currency(symbol: 'Bs. ', decimalDigits: 0);

    final activeOrders = orders.items
        .where((o) => o.status == 'en_produccion' || o.status == 'en_diseno' || o.status == 'listo_para_entrega')
        .toList();

    final pendingQuotes = quotations.items
        .where((q) => q.status == 'pendiente' || q.status == 'borrador')
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF101313),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.print_outlined, color: Color(0xFFFFC400), size: 22),
            SizedBox(width: 8),
            Text(
              'GRAFIK 360 PRO',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 0.5),
            ),
          ],
        ),
        actions: [
          if (app.demoMode)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC400).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFC400).withValues(alpha: 0.6)),
                ),
                child: const Text(
                  'MODO DEMO',
                  style: TextStyle(
                    color: Color(0xFFFFC400),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFFFFC400),
        onRefresh: _refreshAll,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 110),
          children: [
            // Banner de Acceso Rápido y Taller
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1D2224), Color(0xFF131718)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF2E3537), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC400).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.business_outlined, color: Color(0xFFFFC400), size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app.fullName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Text(
                              'Panel de Producción & Cotizaciones',
                              style: TextStyle(color: Color(0xFFA0A7A7), fontSize: 11),
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
                        child: FilledButton.icon(
                          onPressed: () => context.push('/quotations/new'),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Nueva Cotización'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFFC400),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/orders/new'),
                          icon: const Icon(Icons.add_shopping_cart, size: 18),
                          label: const Text('Nuevo Pedido'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFF454E50), width: 1.2),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Tablero de Métricas (2x2)
            GridView.count(
              crossAxisCount: MediaQuery.sizeOf(context).width > 700 ? 4 : 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                MetricCard(
                  label: 'Cotiz. Pendientes',
                  value: '${quotations.pendingCount}',
                  icon: Icons.pending_actions_outlined,
                  color: const Color(0xFFFFC400),
                ),
                MetricCard(
                  label: 'En Fabricación',
                  value: '${orders.inProductionCount}',
                  icon: Icons.precision_manufacturing_outlined,
                  color: const Color(0xFF42A5F5),
                ),
                MetricCard(
                  label: 'Listos p/ Entrega',
                  value: '${orders.readyCount}',
                  icon: Icons.local_shipping_outlined,
                  color: const Color(0xFFFFB300),
                ),
                MetricCard(
                  label: 'Saldos x Cobrar',
                  value: currency.format(orders.totalPendingBalance),
                  icon: Icons.account_balance_wallet_outlined,
                  color: const Color(0xFFFF5252),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Selector de Sección (Segmented Tabs)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF181C1D),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF282D2F)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      label: 'Pedidos en Taller (${activeOrders.length})',
                      icon: Icons.engineering_outlined,
                      active: _selectedTab == 0,
                      onTap: () => setState(() => _selectedTab = 0),
                    ),
                  ),
                  Expanded(
                    child: _TabButton(
                      label: 'Cotizaciones (${pendingQuotes.length})',
                      icon: Icons.request_quote_outlined,
                      active: _selectedTab == 1,
                      onTap: () => setState(() => _selectedTab = 1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Lista según la pestaña seleccionada
            if (_selectedTab == 0) ...[
              if (orders.loading && orders.items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator(color: Color(0xFFFFC400))),
                )
              else if (activeOrders.isEmpty)
                _EmptyCard(
                  title: 'No hay pedidos activos en taller',
                  subtitle: 'Aprueba una cotización o registra un nuevo pedido.',
                  actionText: 'Crear Pedido',
                  onTap: () => context.push('/orders/new'),
                )
              else ...[
                ...activeOrders.take(4).map((order) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: OrderCard(
                        order: order,
                        onTap: () => context.push('/orders/${order.id}'),
                      ),
                    )),
                Center(
                  child: TextButton.icon(
                    onPressed: () => context.go('/orders'),
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('Ver todos los pedidos de taller'),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFFFFC400)),
                  ),
                ),
              ],
            ] else ...[
              if (quotations.loading && quotations.items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator(color: Color(0xFFFFC400))),
                )
              else if (pendingQuotes.isEmpty)
                _EmptyCard(
                  title: 'No hay cotizaciones pendientes',
                  subtitle: 'Crea una nueva cotización con medidas y presupuesto.',
                  actionText: 'Nueva Cotización',
                  onTap: () => context.push('/quotations/new'),
                )
              else ...[
                ...pendingQuotes.take(4).map((quote) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: QuotationCard(
                        quotation: quote,
                        onTap: () => context.push('/quotations/${quote.id}'),
                      ),
                    )),
                Center(
                  child: TextButton.icon(
                    onPressed: () => context.go('/quotations'),
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('Ver todas las cotizaciones'),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFFFFC400)),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFFC400) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17,
              color: active ? Colors.black : const Color(0xFFA0A7A7),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.black : const Color(0xFFA0A7A7),
                fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.title,
    required this.subtitle,
    required this.actionText,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String actionText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const Icon(Icons.folder_open_outlined, size: 36, color: Color(0xFF687070)),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFA0A7A7), fontSize: 12),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.add, size: 16),
              label: Text(actionText),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFC400),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
