class AlarmInfo {
  int? id;
  String alarmDate;
  String location;
  String address;
  String x;
  String y;

  AlarmInfo({this.id, required this.alarmDate, required this.location, required this.address, required this.x, required this.y});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'alarmDate': alarmDate,
      'location': location,
      'address' : address,
      'x': x,
      'y': y,
    };
  }

  @override
  String toString() {
    return 'AlarmInfo{id: $id, alarmDate: $alarmDate, location: $location, address: $address, x: $x, y: $y}';
  }
}
