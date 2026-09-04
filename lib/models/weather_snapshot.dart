class WeatherSnapshot {
  const WeatherSnapshot({
    required this.temperatureC,
    required this.summary,
    required this.weatherCode,
  });

  final double temperatureC;
  final String summary;
  final int weatherCode;
}
