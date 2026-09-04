import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/weather_snapshot.dart';

class WeatherService {
  Future<WeatherSnapshot> currentWeather({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': latitude.toStringAsFixed(6),
      'longitude': longitude.toStringAsFixed(6),
      'current': 'temperature_2m,weather_code',
      'timezone': 'auto',
    });

    final response = await http.get(uri).timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw StateError('API de clima respondió ${response.statusCode}.');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final current = Map<String, dynamic>.from(json['current'] as Map);
    final code = (current['weather_code'] as num?)?.toInt() ?? -1;
    final temperature = (current['temperature_2m'] as num?)?.toDouble() ?? 0;

    return WeatherSnapshot(
      temperatureC: temperature,
      weatherCode: code,
      summary: _describe(code),
    );
  }

  String _describe(int code) {
    if (code == 0) return 'Despejado';
    if ([1, 2, 3].contains(code)) return 'Parcialmente nublado';
    if ([45, 48].contains(code)) return 'Niebla';
    if (code >= 51 && code <= 67) return 'Llovizna / lluvia';
    if (code >= 71 && code <= 77) return 'Nieve';
    if (code >= 80 && code <= 82) return 'Chubascos';
    if (code >= 95) return 'Tormenta';
    return 'Condición variable';
  }
}
