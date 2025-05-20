import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;

class Bmap extends StatefulWidget{
  @override
  _BmapState createState() => _BmapState();
}

class _BmapState extends State<Bmap>{

 @override
  Widget build(BuildContext context) {
    return Scaffold(
  body: FlutterMap(
    options: MapOptions(
      initialCenter: latlng.LatLng(13.568291374486648, 123.15570381693193),
      initialZoom: 15,
      interactionOptions: const InteractionOptions(
        flags: InteractiveFlag.all, // Enables all interactions including zoom
      ),
    ),
       children: [
              openStreetMapTileLayer,
       ],


          /*TileLayer(
            urlTemplate:
                "https://api.mapbox.com/styles/v1/leo-relunia/cm7rwkev4003o01sn3qssdc3h/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}",
            tileProvider: CancellableNetworkTileProvider(),
            additionalOptions: const {
              'accessToken':
                  'pk.eyJ1IjoibGVvLXJlbHVuaWEiLCJhIjoiY203ZXdxdTB1MGZtdTJqcXhlMzI3MXRmNSJ9.vuQO9JwKOEFFrSXs33Rp1g',
              'id': 'mapbox/streets-v11',
            },
          ),*/
        
      ),
    );
  }
  TileLayer get openStreetMapTileLayer => TileLayer(
    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
    userAgentPackageName: 'dev.fleaflet.flutter_map.example',
  );
}
