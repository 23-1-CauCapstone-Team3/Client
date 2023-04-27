
class LocationInfo {
  int? id;
  String location;
  String address;

  LocationInfo({this.id, required this.location, required this.address});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'location': location,
      'address': address,
    };
  }

  @override
  String toString() {
    return 'LocationInfo{id: $id, location: $location, address: $address}';
  }
}