import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_finder/bloc/bloc.dart';
import 'package:location_finder/models/place.dart';
import 'package:location_finder/services/google_service_provider.dart';

class GoogleAddressBloc implements Bloc {
  GoogleServiceProvider _googleServiceProvider;
  final String _googleServiceApiKey;

//-------------------------- stream setup for searching place----------------------
  // event stream to get search text
  final searchEventStreamController = StreamController<String>();
  StreamSink<String> get searchEventSink => searchEventStreamController.sink;
  Stream<String> get _searchEventStream => searchEventStreamController.stream;

  // Stream that provides places that match the search text
  final placeStreamController = StreamController<List<Place>>();
  StreamSink<List<Place>> get _placeSink => placeStreamController.sink;
  Stream<List<Place>> get placeStream => placeStreamController.stream;
  //--------------------------place search ends here-------------------------------

  //--------------------------stream setup for selection and marking of place in map-------
  final addressStreamController = StreamController<Place>.broadcast();
  StreamSink<Place> get _addressSink => addressStreamController.sink;
  Stream<Place> get addressStream => addressStreamController.stream;

  final addressSelectEventStreamController = StreamController<Place>();
  StreamSink<Place> get addressSelectEventSink =>
      addressSelectEventStreamController.sink;
  Stream<Place> get _addressSelectEventStream =>
      addressSelectEventStreamController.stream;
  //--------------------------------------------------------------------------------

// event stream to get search text
  final geoCodeController = StreamController<LatLng>();
  StreamSink<LatLng> get geoCodeSearchEventSink => geoCodeController.sink;
  Stream<LatLng> get _geoCodeSearchEventStream => geoCodeController.stream;

  GoogleAddressBloc(this._googleServiceApiKey) {
    this._googleServiceProvider =
        new GoogleServiceProvider(apiKey: this._googleServiceApiKey);

    _searchEventStream.listen((searchText) async {
      if (searchText.isNotEmpty && searchText.contains(',')) {
        var places = await _googleServiceProvider.searchPlaces(searchText);
        _placeSink.add(places);
      } else {
        _placeSink.add([]);
      }
    });

    _addressSelectEventStream.listen((selectedPlace) async {
      //When a place selected, get the lat, long,long address description and pincode from google.
      var place = await this._googleServiceProvider.address(selectedPlace);
      _addressSink.add(place);
    });

    _geoCodeSearchEventStream.listen((latlng) async {
      var place =
          await this._googleServiceProvider.getAddressFromLatLng(latlng);
      _addressSink.add(place);
    });
  }

  @override
  void dispose() {
    searchEventStreamController.close();
    placeStreamController.close();
    addressSelectEventStreamController.close();
    addressStreamController.close();
    geoCodeController.close();
  }
}
