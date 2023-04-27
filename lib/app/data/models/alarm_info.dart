
class AlarmInfo {
  int? id;
  String alarmDate;
  String location;

  AlarmInfo({this.id, required this.alarmDate, required this.location});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'alarmDate': alarmDate,
      'location': location,
    };
  }

  @override
  String toString() {
    return 'AlarmInfo{id: $id, alarmDate: $alarmDate, location: $location}';
  }
}
