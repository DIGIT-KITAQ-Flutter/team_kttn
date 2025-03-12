import 'package:digit_kttn/chat/chat.dart';
import 'package:digit_kttn/map/marker_color.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'load_stations.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Marker> _markers = [];
  List<Station> stations = []; // 駅データのリスト

  @override
  void initState() {
    super.initState();
    loadStationData();
  }

  // 駅データをロード
  Future<void> loadStationData() async {
    stations = await loadStations();

    if (stations.isNotEmpty) {
      listenToCrowdingUpdates(); // 駅データ取得後に Firestore のリスニングを開始
    }

    setState(() {}); // UIを更新
  }

  // Firestoreから混雑情報をリッスン
  void listenToCrowdingUpdates() {
    FirebaseFirestore.instance
        .collection('station_chats')
        .snapshots()
        .listen((snapshot) {
      Map<String, List<String>> stationCrowdingData = {};

      for (var doc in snapshot.docs) {
        String stationId = doc['station_id'].toString();
        String crowdingLevel = doc['crowding_level'];

        if (!stationCrowdingData.containsKey(stationId)) {
          stationCrowdingData[stationId] = [];
        }
        stationCrowdingData[stationId]!.add(crowdingLevel);
      }

      updateMarkers(stationCrowdingData);
    });
  }

  // マーカーの更新
  Future<void> updateMarkers(
      Map<String, List<String>> stationCrowdingData) async {
    List<Marker> updatedMarkers = []; // 新しいマーカーリスト

    for (var station in stations) {
      String stationId = station.stationId.toString();
      List<String> crowdingLevels = stationCrowdingData[stationId] ?? [];

      // 混雑状況の集計
      String majorityCrowdingLevel = getMajorityCrowdingLevel(crowdingLevels);

      // マーカーを更新
      updatedMarkers.add(
        Marker(
          point: LatLng(station.latitude, station.longitude),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    station_id: station.stationId, // station_id を渡す
                    name: station.name, // name を渡す
                  ),
                ),
              );
            },
            child: Icon(
              Icons.location_on,
              color: getMarkerColor(majorityCrowdingLevel), // 混雑状況に応じた色を設定
              size: 40.0,
            ),
          ),
        ),
      );
    }

    setState(() {
      _markers = updatedMarkers; // 更新されたマーカーを画面に反映
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('駅マップ'),
      ),
      body: stations.isEmpty // 駅データが読み込まれるまで待機
          ? Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(33.8833, 130.8833),
                initialZoom: 14,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(markers: _markers),
              ],
            ),
    );
  }
}
