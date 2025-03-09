import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Map'),
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              // アイコンが押されたときの処理をここに追加します
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                // ログアウトボタンが押されたときの処理をここに追加します
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            MapScreen(),
            Positioned(
              top: 10.0,
              left: 10.0,
              right: 10.0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: TextEditingController(),
                  decoration: InputDecoration(
                    hintText: '検索',
                    border: InputBorder.none,
                    icon: Icon(Icons.search),
                  ),
                  onSubmitted: (value) {
                    // 検索バーに入力された値を処理する
                    _MapScreenState? mapScreenState = context.findAncestorStateOfType<_MapScreenState>();
                    mapScreenState?.filterStations(value);
                  },
                ),
              ),
            ),
            DraggableScrollableSheet(
              initialChildSize: 0.1,
              minChildSize: 0.1,
              maxChildSize: 0.5,
              builder: (BuildContext context, ScrollController scrollController) {
                return Container(
                  color: Colors.white,
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: 20, // コメントの数に応じて変更
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage('assets/profile.jpg'),
                        ),
                        title: Text('Dummy comment $index - This is a sample comment.'),
                        subtitle: Text('${index + 1} days ago'),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  List<dynamic> _stations = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    final String response = await rootBundle.loadString('assets/stations.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      _stations = data;
      _markers = _stations.map((station) {
        return Marker(
          width: 80.0,
          height: 80.0,
          point: LatLng(station['latitude'], station['longitude']),
          builder: (ctx) => Container(
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

  void filterStations(String query) {
    final filteredStations = _stations.where((station) {
      final stationName = station['name'].toLowerCase();
      final input = query.toLowerCase();
      return stationName.contains(input);
    }).toList();

    setState(() {
      _markers = filteredStations.map((station) {
        return Marker(
          width: 80.0,
          height: 80.0,
          point: LatLng(station['latitude'], station['longitude']),
          builder: (ctx) => Container(
            child: Icon(
              Icons.location_on,
              color: Colors.red,
              size: 40.0,
            ),
          ),
        );
      }).toList();

      if (filteredStations.isNotEmpty) {
        final firstStation = filteredStations.first;
        _mapController.move(
          LatLng(firstStation['latitude'], firstStation['longitude']),
          14.0,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: LatLng(33.8833, 130.8757), // 北九州市の緯度経度
        zoom: 14.0,
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
