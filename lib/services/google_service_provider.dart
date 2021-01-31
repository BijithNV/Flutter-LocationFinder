import 'dart:convert' as convert;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location_finder/models/place.dart';

class GoogleServiceProvider {
  final String apiKey;
  final String _placeAutoCompleteUrl =
      "https://maps.googleapis.com/maps/api/place/autocomplete/json?";

  final String _addressApiUrl =
      'https://maps.googleapis.com/maps/api/place/details/json?';

  final String _geoCodeApiUrl =
      'https://maps.googleapis.com/maps/api/geocode/json?';

  GoogleServiceProvider({this.apiKey}) {
    print('initializing google service provider : $apiKey');
  }

  Future<List<Place>> searchPlaces(String value) async {
    var url = _placeAutoCompleteUrl + 'input=$value&key=$apiKey';
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);

      List<Place> places = List<Place>.from(
          jsonResponse['predictions'].map((model) => Place.fromJson(model)));

      return places;
    }
    return null;
  }

  Future<Place> address(Place place) async {
    var url = _addressApiUrl + 'place_id=${place.placeId}&key=$apiKey';
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      print('*************$jsonResponse');
      place.formatAddress = jsonResponse["result"]["formatted_address"];
      place.address = jsonResponse["result"]["adr_address"];
      place.lat = jsonResponse["result"]["geometry"]["location"]["lat"];
      place.lng = jsonResponse["result"]["geometry"]["location"]["lng"];
      return place;
    }

    return null;
  }

  Future<Place> getAddressFromLatLng(LatLng latlng) async {
    var url = _geoCodeApiUrl +
        'latlng=${latlng.latitude},${latlng.longitude}&key=$apiKey';
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      var place = Place(
          jsonResponse['results'][0]["place_id"],
          '',
          jsonResponse['results'][0]["formatted_address"],
          jsonResponse['results'][0]["formatted_address"],
          jsonResponse['results'][0]["geometry"]["location"]["lat"],
          jsonResponse['results'][0]["geometry"]["location"]["lng"]);
      return place;
    }
    return null;
  }
}
