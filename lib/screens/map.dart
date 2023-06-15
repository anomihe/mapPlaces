import 'package:favouriteplaces/model/place.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  final PlaceLocation location;
  final bool isSelecting;
  const MapScreen(
      {Key? key,
      this.isSelecting = true,
      this.location = const PlaceLocation(
          address: '', longitude: 47.4532, latitude: -122.084)})
      : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _pickedLoaction;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isSelecting ? 'Pick your Location' : 'Your Location',
        ),
        actions: [
          if (widget.isSelecting)
            IconButton(
              onPressed: () {
                Navigator.of(context).pop(_pickedLoaction);
              },
              icon: const Icon(Icons.save),
            ),
        ],
      ),
      body: GoogleMap(
        onTap: !widget.isSelecting
            ? null
            : (postion) {
                _pickedLoaction = postion;
              },
        initialCameraPosition: CameraPosition(
          target: LatLng(
            widget.location.latitude,
            widget.location.latitude,
          ),
          zoom: 16,
        ),
        markers: (_pickedLoaction == null && widget.isSelecting == true)
            ? {}
            : {
                Marker(
                  //this is a more concise way
                  //position: _pickedLocation?? LatLng(w)
                  position: _pickedLoaction == null
                      ? _pickedLoaction!
                      : LatLng(
                          widget.location.latitude,
                          widget.location.longitude,
                        ),
                  markerId: const MarkerId('m1'),
                )
              },
      ),
    );
  }
}
