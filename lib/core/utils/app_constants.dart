class AppConstants {
  static const appName = 'GRAFIK 360 PRO';
  static const appSubtitle = 'Industria Gráfica & Soluciones Publicitarias';
  static const osmUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const osmCopyrightUrl = 'https://www.openstreetmap.org/copyright';
  static const defaultLatitude = -21.53549;
  static const defaultLongitude = -64.72956;
  static const storageBucket = 'graphic-assets';

  /// Categorías de servicios y productos de publicidad e industria gráfica
  static const categories = <String>[
    'Banners y Gigantografías',
    'Stands Publicitarios',
    'Letreros en Acrílico',
    'Rotulación y Vinilos',
    'Letras Corpóreas / Neón LED',
    'Impresión Digital / Afiches',
    'Estructuras Metálicas',
    'Merchandising / Sublimación',
    'Otro',
  ];

  /// Estados para el ciclo de vida de una Cotización
  static const quotationStatuses = <String>[
    'borrador',
    'pendiente',
    'aprobada',
    'rechazada',
  ];

  /// Estados para el ciclo de vida de un Pedido / Orden de Producción
  static const orderStatuses = <String>[
    'en_diseno',
    'en_produccion',
    'listo_para_entrega',
    'instalado_entregado',
    'cancelado',
  ];
}
