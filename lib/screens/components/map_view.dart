import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_finder/bloc/bloc_provider.dart';
import 'package:location_finder/bloc/google_address_bloc.dart';
import 'package:location_finder/constants/location_finder_type_defs.dart';
import 'package:location_finder/models/place.dart';

class MapView extends StatefulWidget {
  final LatLng initialLocation;
  //final _isUserMovingMarker = false;
  final LocationMarkedEvent onLocationMarked;

  MapView({Key key, this.initialLocation, this.onLocationMarked})
      : super(key: key);

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController _mapController;
  var _locationMark = Set<Marker>();
  var _isUserMovingMarker = false;
  var _enableMarkerMove = false;

  @override
  Widget build(BuildContext context) {
    var _googleAddressBloc = BlocProvider.of<GoogleAddressBloc>(context);
    return StreamBuilder<Place>(
        stream: _googleAddressBloc.addressStream,
        builder: (context, snapshot) {
          print('user marking : $_isUserMovingMarker');

          if (snapshot.hasData && !_isUserMovingMarker) {
            var _position = LatLng(snapshot.data.lat, snapshot.data.lng);
            markSelectedAddressInMap(_position, canAnimateCamera: true);
            FocusScope.of(context).requestFocus(FocusNode());
            //Allow user to move marker
            _enableMarkerMove = true;
          }

          // setting flag to false when an address is set while search with criteria.
          _isUserMovingMarker = false;
          widget.onLocationMarked(snapshot.data);

          return GoogleMap(
            mapType: MapType.normal,
            onMapCreated: (controller) {
              this._mapController = controller;
            },
            initialCameraPosition:
                CameraPosition(target: widget.initialLocation, zoom: 10),
            onTap: (argument) {
              // Allow user to choose precise spot after focusing map with search criteria.
              if (_enableMarkerMove) {
                var newLtlng = LatLng(argument.latitude, argument.longitude);

                markSelectedAddressInMap(newLtlng);
                _isUserMovingMarker = true;
                BlocProvider.of<GoogleAddressBloc>(context)
                    .geoCodeSearchEventSink
                    .add(newLtlng);
              }
            },
            markers: _locationMark,
          );
        });
  }

  void markSelectedAddressInMap(LatLng _position,
      {bool canAnimateCamera = false}) {
    _locationMark.clear();
    _locationMark.add(Marker(
        markerId: MarkerId('locationMark'),
        position: _position,
        onDragEnd: (value) {
          print('Marker dragging end');
        },
        draggable: true));

    if (canAnimateCamera)
      _mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _position, zoom: 16),
      ));
  }
}
