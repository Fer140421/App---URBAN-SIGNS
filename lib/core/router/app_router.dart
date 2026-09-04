import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/order.dart';
import '../../models/quotation.dart';
import '../../screens/orders/order_detail_screen.dart';
import '../../screens/orders/order_form_screen.dart';
import '../../screens/quotations/quotation_detail_screen.dart';
import '../../screens/quotations/quotation_form_screen.dart';
import '../../screens/shell/app_gate.dart';
import '../../screens/shell/main_shell.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AppGate(),
      ),
      GoRoute(
        path: '/quotations',
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: const MainShell(initialIndex: 1),
        ),
      ),
      GoRoute(
        path: '/quotations/new',
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: const QuotationFormScreen(),
        ),
      ),
      GoRoute(
        path: '/quotations/:id',
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: QuotationDetailScreen(id: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/quotations/:id/edit',
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: QuotationFormScreen(initial: state.extra as Quotation?),
        ),
      ),
      GoRoute(
        path: '/orders',
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: const MainShell(initialIndex: 2),
        ),
      ),
      GoRoute(
        path: '/orders/new',
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: const OrderFormScreen(),
        ),
      ),
      GoRoute(
        path: '/orders/:id',
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: OrderDetailScreen(id: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/orders/:id/edit',
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: OrderFormScreen(initial: state.extra as Order?),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Ruta no disponible: ${state.uri}')),
    ),
  );
}
