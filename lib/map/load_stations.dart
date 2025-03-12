import 'dart:convert';
import 'package:flutter/services.dart';

class Station {
  final int stationId;
  final String name;
  final double latitude;
  final double longitude;

  Station({
    required this.stationId,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      stationId: json['station_id'],
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}

Future<List<Station>> loadStations() async {
  // JSON ファイルを読み込む
  final String response =
      await rootBundle.loadString('assets/json/stations.json');
  final List<dynamic> data = json.decode(response);

  // JSON を Station オブジェクトに変換
  return data.map((json) => Station.fromJson(json)).toList();
}
