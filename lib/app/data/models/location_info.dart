class LocationInfo {
  int? id;
  String location;
  String address;
  String x;
  String y;

  LocationInfo({this.id, required this.location, required this.address, required this.x, required this.y});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'location': location,
      'address': address,
      'x': x,
      'y': y,
    };
  }

  @override
  String toString() {
    return 'LocationInfo{id: $id, location: $location, address: $address, x: $x, y:$y}';
  }
}
