import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/app_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const yellow = Color(0xFFFFC400);
  static const background = Color(0xFF101313);
  static const card = Color(0xFF181C1D);
  static const muted = Color(0xFFA0A7A7);

  @override
  Widget build(BuildContext context) {
    final demoMode = context.watch<AppController>().demoMode;
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Row(children: [
          Icon(Icons.signpost_outlined, color: yellow, size: 22),
          SizedBox(width: 8),
          Text('URBAN SIGNS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: .5)),
        ]),
        actions: [if (demoMode) const Padding(
          padding: EdgeInsets.only(right: 12),
          child: Center(child: Text('MODO DEMO', style: TextStyle(color: yellow, fontSize: 10, fontWeight: FontWeight.w900))),
        )],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
        children: const [
          _Hero(),
          SizedBox(height: 18),
          _Title(Icons.business_outlined, 'Quiénes somos'),
          SizedBox(height: 8),
          _Box(child: Text(
            'Urban Signs transforma ideas en soluciones visuales de alto impacto. Acompañamos cada proyecto desde el diseño y la planificación hasta la producción, entrega e instalación.',
            style: TextStyle(color: Color(0xFFD2D7D7), height: 1.55, fontSize: 13.5),
          )),
          SizedBox(height: 18),
          _Title(Icons.auto_awesome_outlined, 'Nuestros servicios'),
          SizedBox(height: 8),
          _Services(),
          SizedBox(height: 18),
          _Title(Icons.workspace_premium_outlined, 'Nuestro compromiso'),
          SizedBox(height: 8),
          _Box(child: Column(children: [
            _Value(Icons.design_services_outlined, 'Diseño que comunica', 'Propuestas visuales alineadas con la identidad de cada cliente.'),
            Divider(color: Color(0xFF2B3133), height: 24),
            _Value(Icons.precision_manufacturing_outlined, 'Producción de calidad', 'Materiales y procesos elegidos para resultados duraderos.'),
            Divider(color: Color(0xFF2B3133), height: 24),
            _Value(Icons.handshake_outlined, 'Atención responsable', 'Seguimiento claro desde la solicitud hasta la entrega final.'),
          ])),
          SizedBox(height: 18),
          _Closing(),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF242A2B), Color(0xFF15191A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF353D3F)),
    ),
    child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(Icons.storefront_outlined, color: DashboardScreen.yellow, size: 34),
      SizedBox(height: 18),
      Text('HACEMOS VISIBLE\nTU MARCA', style: TextStyle(color: Colors.white, fontSize: 27, height: 1.05, fontWeight: FontWeight.w900)),
      SizedBox(height: 10),
      Text('Diseño, producción e instalación de publicidad visual para espacios que destacan.', style: TextStyle(color: DashboardScreen.muted, fontSize: 13.5, height: 1.45)),
    ]),
  );
}

class _Title extends StatelessWidget {
  const _Title(this.icon, this.text);
  final IconData icon; final String text;
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, color: DashboardScreen.yellow, size: 19), const SizedBox(width: 8),
    Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
  ]);
}

class _Box extends StatelessWidget {
  const _Box({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(color: DashboardScreen.card, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFF2B3133))),
    child: child,
  );
}

class _Services extends StatelessWidget {
  const _Services();
  static const items = [
    (Icons.panorama_wide_angle_outlined, 'Banners y gigantografías'),
    (Icons.store_mall_directory_outlined, 'Letreros y fachadas'),
    (Icons.format_color_fill_outlined, 'Rotulación y vinilos'),
    (Icons.lightbulb_outline, 'Letras corpóreas y neón'),
    (Icons.view_in_ar_outlined, 'Stands publicitarios'),
    (Icons.construction_outlined, 'Montaje e instalación'),
  ];
  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: items.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.45),
    itemBuilder: (_, index) => Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: DashboardScreen.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF2B3133))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(items[index].$1, color: DashboardScreen.yellow, size: 24), const SizedBox(height: 9),
        Text(items[index].$2, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12.5)),
      ]),
    ),
  );
}

class _Value extends StatelessWidget {
  const _Value(this.icon, this.title, this.subtitle);
  final IconData icon; final String title; final String subtitle;
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, color: DashboardScreen.yellow, size: 22), const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13.5)),
      const SizedBox(height: 3), Text(subtitle, style: const TextStyle(color: DashboardScreen.muted, fontSize: 12, height: 1.35)),
    ])),
  ]);
}

class _Closing extends StatelessWidget {
  const _Closing();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: DashboardScreen.yellow, borderRadius: BorderRadius.circular(15)),
    child: const Row(children: [
      Icon(Icons.location_city_outlined, color: Colors.black, size: 28), SizedBox(width: 13),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('URBAN SIGNS', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16)),
        SizedBox(height: 3), Text('Ideas que toman forma. Marcas que se hacen visibles.', style: TextStyle(color: Color(0xCC000000), fontWeight: FontWeight.w700, fontSize: 12)),
      ])),
    ]),
  );
}
