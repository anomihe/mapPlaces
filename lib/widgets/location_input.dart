import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

import '../model/place.dart';

class LoationInput extends StatefulWidget {
  final void Function(PlaceLocation loction) onSelectLocation;
  const LoationInput({Key? key, required this.onSelectLocation})
      : super(key: key);

  @override
  State<LoationInput> createState() => _LoationInputState();
}

class _LoationInputState extends State<LoationInput> {
  PlaceLocation? _pickedLocation;
  var _isGettingLocation = true;
  String get locationImage {
    final lat = _pickedLocation!.latitude;
    final lng = _pickedLocation!.longitude;
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng=&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$lat,$lng&key=AIzaSyDlcwxUggpPZo9lcbH0TB4CrqssJjtj4ag';
  }

  void _getCurrentLocation() async {
    Location location = Location();
    bool serviceEnable;
    PermissionStatus permissionGranted;
    LocationData locationData;
    serviceEnable = await location.serviceEnabled();
    if (!serviceEnable) {
      serviceEnable = await location.requestService();
      if (!serviceEnable) {
        return;
      }
    }
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    setState(() {
      _isGettingLocation = true;
    });
    locationData = await location.getLocation();
    final lat = locationData.latitude;
    final lng = locationData.longitude;
    if (lat == null || lng == null) {
      return;
    }
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=AIzaSyDlcwxUggpPZo9lcbH0TB4CrqssJjtj4ag');
    final response = await http.get(url);
    final resData = json.decode(response.body);
    final address = resData['result'][0]['formatted_address'];

    setState(() {
      _pickedLocation = PlaceLocation(
        address: address,
        longitude: lng,
        latitude: lat,
      );
      _isGettingLocation = false;
    });
    widget.onSelectLocation(_pickedLocation!);
  }

  void _selectOnMap() {}

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      'No Location chosen',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.onBackground,
          ),
    );
    if (_pickedLocation != null) {
      previewContent = Image.network(
        locationImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    if (_isGettingLocation) {
      previewContent = const CircularProgressIndicator();
    }
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          height: 170,
          decoration: BoxDecoration(
              border: Border.all(
            width: 1,
            color: Theme.of(context).colorScheme.primary,
          )),
          child: previewContent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.location_on),
              label: const Text('Get Current Location'),
            ),
            TextButton.icon(
              onPressed: _selectOnMap,
              icon: const Icon(Icons.map),
              label: const Text('Select on Map'),
            ),
          ],
        )
      ],
    );
  }
}
