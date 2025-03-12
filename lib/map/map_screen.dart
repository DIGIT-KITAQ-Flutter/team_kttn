import 'dart:convert';
import 'package:digit_kttn/chat/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    final String response =
        await rootBundle.loadString('assets/json/stations.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      _markers = data.map((station) {
        return Marker(
          width: 80.0, // 幅を80に設定
          height: 80.0, // 高さを80に設定
          point: LatLng(station['latitude'], station['longitude']), // 緯度経度を使用
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // builder: (context) => ChatScreen(
                  //     station_id: station['station_id'] is int
                  //         ? station['station_id']
                  //         : int.tryParse(station['station_id'].toString()) ?? 0,
                  //     name: station['name']),
                  builder: (context) => ChatScreen(
                      station_id: station['station_id'], name: station['name']),
                ),
              );
            },
            child: Icon(
              Icons.location_on,
              color: Colors.red,
              size: 40.0,
            ),
          ),
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(33.8833, 130.8757), // 北九州市の緯度経度
        initialZoom: 14.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
        ),
        MarkerLayer(
          markers: _markers,
        ),
      ],
    );
  }
}
