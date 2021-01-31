class Place {
  String name;
  String address;
  String formatAddress;
  String placeId;
  String description;
  double lat;
  double lng;

  Place(this.placeId, this.name, this.address, this.description, this.lat,
      this.lng);

  static List<Place> fromNative(List results) {
    return results.map((p) => Place.fromJson(p)).toList();
  }

  factory Place.fromJson(Map<dynamic, dynamic> json) => Place(
      json['place_id'],
      json['name'],
      json['address'] != null ? json['address'] : "",
      json['description'],
      json['lat'],
      json['lng']);
}
