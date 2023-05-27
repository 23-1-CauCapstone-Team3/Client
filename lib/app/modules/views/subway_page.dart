import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../../data/theme_data.dart';
import 'home.dart';

class SubwayPage extends StatefulWidget {
  const SubwayPage({Key? key}) : super(key: key);

  @override
  _SubwayPage createState() => _SubwayPage();
}

class _SubwayPage extends State<SubwayPage> {
  var exBox = Hive.box('box_name');

  late List route = []; // Hive
  late DateTime departureTime = DateTime.now();
  late Duration duration = departureTime.difference(DateTime.now());
  Timer? _timer;

  late int subPathIndex = 0; // Hive
  late int currentRouteType = 3; // Hive

  late int currentStation = 0; // TODO
  late List stations = [];

  late double currentLongitude = 0.0;
  late double currentLatitude = 0.0;

  void _startTimer() {
    duration = departureTime.difference(DateTime.now());

    if (duration.inSeconds > 0) {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        _setCountDown();
      });
    }else{
      setState(() {
        duration = const Duration(seconds: 0);
      });
    }
  }

  void _stopTimer() {
    setState(() {
      _timer!.cancel();
    });
  }

  void _setCountDown() {
    const reduceSecondsBy = 1;
    setState(() {
      final seconds = duration.inSeconds - reduceSecondsBy;
      if (seconds - 1 < 0) {
        duration = const Duration(seconds: 0);
        _timer!.cancel();
      } else {
        duration = Duration(seconds: seconds);
        findCurrentStation();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    route = exBox.get('route', defaultValue: []);

    subPathIndex = exBox.get('subPathIndex', defaultValue: 0);
    currentRouteType = exBox.get('nextRouteType', defaultValue: 3);

    stations = route[subPathIndex]["passStopList"]["stations"];

    findCurrentStation();

    if (route[subPathIndex + 1]['trafficType'] == 4) {
      departureTime = DateFormat('yyyy-MM-ddTHH:mm:ss').parse(route[subPathIndex + 2]["lane"][0]["departureTime"]);
      duration = departureTime.difference(DateTime.now());

      if (duration.inSeconds < 0) duration = const Duration(seconds: 0);

    } else {
      departureTime = DateTime.now();
      duration = departureTime.difference(DateTime.now());

      if (duration.inSeconds < 0) duration = const Duration(seconds: 0);
    }

    if (duration.inSeconds > 0) {
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    String strDigits(int n) => n.toString().padLeft(2, '0');
    final hours = strDigits(duration.inHours.remainder(24));
    final minutes = strDigits(duration.inMinutes.remainder(60));
    final seconds = strDigits(duration.inSeconds.remainder(60));

    return Scaffold(
        backgroundColor: CustomColors.pageBackgroundColor,
        body: Container(
            padding: const EdgeInsets.fromLTRB(15, 50, 15, 0),
            child: SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  '경로 미리보기',
                  style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 20),
                ),
                SizedBox(height: 5),
                Divider(
                  color: Colors.white54,
                ),
                SizedBox(
                  // height: 200,
                  width: 380,
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(top: 0),
                    itemCount: route.length - subPathIndex,
                    itemBuilder: (context, index) {
                      return Align(
                          alignment: Alignment.centerLeft,
                          child: Row(children: [
                            SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              width: 30,
                              child: _transportIcon(index + subPathIndex),
                            ),
                            SizedBox(
                              width: 60,
                              child: _transportName(index + subPathIndex),
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            SizedBox(
                              height: 20,
                              child: Text(
                                '${route[index + subPathIndex]["startName"]}',
                                style: const TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 20),
                              ),
                            ),
                          ]));
                    },
                  ),
                ),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Row(children: [
                      SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        width: 30,
                        child: _transportIcon(-1),
                      ),
                      SizedBox(
                        width: 60,
                        child: _transportName(-1),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      SizedBox(
                        height: 20,
                        child:
                        Text(
                          '${route[route.length - 1]["endName"]}',
                          style: const TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 20),
                        ),
                      ),
                    ])),
                Divider(
                  color: Colors.white54,
                ),
                SizedBox(height: 5),
                if (route[subPathIndex + 1]['trafficType'] == 4) ...[
                  if (route[subPathIndex + 2]['trafficType'] == 1) ...[
                    // 다음 대중교통: 지하철
                    Text(
                      '탑승 예정 열차 정보',
                      style: const TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 20),
                    ),
                    SizedBox(height: 5),
                    Divider(
                      color: Colors.white54,
                    ),
                    Text(
                      '${route[subPathIndex + 2]["startName"]}역에서 ${route[subPathIndex + 2]["lane"][0]["name"]} 탑승',
                      style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 20),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: <Widget>[
                        Text(
                          '열차 도착까지 ',
                          style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 20),
                        ),
                        SizedBox(
                          width: 100,
                          child: Text(
                            '$hours:$minutes:$seconds', // TODO: '$hours:$minutes:$seconds',
                            style: const TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 20),
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            '남았습니다',
                            style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 20),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 5),
                    Divider(
                      color: Colors.white54,
                    ),
                  ]
                  else if (route[subPathIndex + 2]['trafficType'] == 2) ...[
                    // 다음 대중교통: 버스
                    Text(
                      '탑승 예정 버스 정보',
                      style: const TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 20),
                    ),
                    SizedBox(height: 5),
                    Divider(
                      color: Colors.white54,
                    ),
                    Text(
                      '${route[subPathIndex + 2]["startName"]} 정류장에서 ${route[subPathIndex + 2]["lane"][0]["busNo"]} 버스 탑승',
                      style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 20),
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          '버스 도착까지 ',
                          style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 20),
                        ),
                        SizedBox(
                          width: 100,
                          child: Text(
                            '$hours:$minutes:$seconds', // TODO: '$hours:$minutes:$seconds',
                            style: const TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 20),
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            '남았습니다',
                            style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 20),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 5),
                    Divider(
                      color: Colors.white54,
                    ),
                  ]
                  else ...[
                    // 다음 대중교통: 택시
                    // TODO
                  ],
                ],
                SizedBox(height: 10),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Column(children: [
                      Row(children: [
                        SizedBox(
                          width: 10,
                        ),
                        Icon(Icons.radio_button_unchecked, color: TransportColors.subway[route[subPathIndex]["lane"][0]["subwayCode"]]),
                        SizedBox(
                          width: 5,
                        ),
                        SizedBox(
                          height: 20,
                          child: Text(
                            '${stations[currentStation]["stationName"]}',
                            style: const TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ]),
                      Row(children: [
                        SizedBox(
                          width: 20,
                        ),
                        Container(
                          width: 2,
                          height: 10,
                          color: TransportColors.subway[route[subPathIndex]["lane"][0]["subwayCode"]],
                        ),
                      ]),
                      SizedBox(
                        height: 0,
                        child: Row(children: [
                          SizedBox(
                            width: 9,
                          ),
                          Icon(Icons.arrow_drop_down, color: TransportColors.subway[route[subPathIndex]["lane"][0]["subwayCode"]]),
                        ]),
                      ),
                      Row(children: [
                        SizedBox(
                          width: 20,
                        ),
                        Container(
                          width: 2,
                          height: 10,
                          color: TransportColors.subway[route[subPathIndex]["lane"][0]["subwayCode"]],
                        ),
                      ]),
                      SizedBox(
                        height: 0,
                        child: Row(children: [
                          SizedBox(
                            width: 9,
                          ),
                          Icon(Icons.arrow_drop_down, color: TransportColors.subway[route[subPathIndex]["lane"][0]["subwayCode"]]),
                        ]),
                      ),
                      Row(children: [
                        SizedBox(
                          width: 20,
                        ),
                        Container(
                          width: 2,
                          height: 10,
                          color: TransportColors.subway[route[subPathIndex]["lane"][0]["subwayCode"]],
                        ),
                      ]),
                      SizedBox(
                        height: 0,
                        child: Row(children: [
                          SizedBox(
                            width: 9,
                          ),
                          Icon(Icons.arrow_drop_down, color: TransportColors.subway[route[subPathIndex]["lane"][0]["subwayCode"]]),
                        ]),
                      ),
                      Row(children: [
                        SizedBox(
                          width: 20,
                        ),
                        Container(
                          width: 2,
                          height: 15,
                          color: TransportColors.subway[route[subPathIndex]["lane"][0]["subwayCode"]],
                        ),
                      ]),Row(children: [
                        SizedBox(
                          width: 20,
                        ),
                        Container(
                          width: 2,
                          height: 15,
                          color: TransportColors.subway[route[subPathIndex]["lane"][0]["subwayCode"]],
                        ),
                      ]),
                      if (route[subPathIndex]["stationCount"] - currentStation > 1) ...[ Row(children: [
                        SizedBox(
                          width: 10,
                        ),
                        Icon(Icons.radio_button_unchecked, color: TransportColors.subway[route[subPathIndex]["lane"][0]["subwayCode"]]),
                        SizedBox(
                          width: 5,
                        ),
                        SizedBox(
                          height: 20,
                          child: Text(
                            '${stations[currentStation+1]["stationName"]}',
                            style: const TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ])],
                      Row(children: [
                        SizedBox(
                          width: 20,
                        ),
                        Container(
                          width: 2,
                          height: 20,
                          color: TransportColors.subway[route[subPathIndex]["lane"][0]["subwayCode"]],
                        ),
                      ])
                    ])),
                if (route[subPathIndex]["stationCount"] - currentStation > 3) ...[
                  ExpansionTile(
                      title: Row(children: [
                        SizedBox(
                          width: 4,
                        ),
                        Container(
                          width: 2,
                          height: 50,
                          color: TransportColors.subway[route[subPathIndex]["lane"][0]["subwayCode"]],
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text('${route[subPathIndex]["stationCount"] - currentStation - 2}개 역 이동',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              fontFamily: 'NanumSquareNeo',
                            ))
                      ]),
                      initiallyExpanded: false,
                      maintainState: true,
                      backgroundColor: CustomColors.pageBackgroundColor,
                      children: <Widget>[
                        SizedBox(
                          // height: 200,
                          width: 380,
                          child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            padding: const EdgeInsets.only(top: 0),
                            itemCount: stations.length - currentStation - 3,
                            itemBuilder: (context, index) {
                              return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Column(children: [
                                    Row(children: [
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Icon(Icons.radio_button_unchecked, color: TransportColors.subway[route[subPathIndex]["lane"][0]["subwayCode"]]),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      SizedBox(
                                        height: 20,
                                        child: Text(
                                          '${stations[index + 2 + currentStation]["stationName"]}',
                                          style: const TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 20),
                                        ),
                                      ),
                                    ]),
                                    Row(children: [
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Container(
                                        width: 2,
                                        height: 10,
                                        color: TransportColors.subway[route[subPathIndex]["lane"][0]["subwayCode"]],
                                      ),
                                    ])
                                  ]));
                            },
                          ),
                        ),
                        Row(children: [
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            width: 2,
                            height: 20,
                            color: TransportColors.subway[route[subPathIndex]["lane"][0]["subwayCode"]],
                          ),
                        ]),
                        Row(children: [
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            width: 2,
                            height: 20,
                            color: TransportColors.subway[route[subPathIndex]["lane"][0]["subwayCode"]],
                          ),
                        ]),
                      ])
                ],

                Row(children: [
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                    width: 2,
                    height: 20,
                    color: TransportColors.subway[route[subPathIndex]["lane"][0]["subwayCode"]],
                  ),
                ]),
                Row(children: [
                  SizedBox(
                    width: 10,
                  ),
                  Icon(Icons.radio_button_unchecked, color: TransportColors.subway[route[subPathIndex]["lane"][0]["subwayCode"]]),
                  SizedBox(
                    width: 5,
                  ),
                  SizedBox(
                    height: 20,
                    child: Text(
                      '${stations[route[subPathIndex]["stationCount"]]["stationName"]} 하차',
                      style: const TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 20),
                    ),
                  ),
                ]),
                const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  OutlinedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          fixedSize: Size(150, 50),
                          textStyle: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 20,
                            fontFamily: 'NanumSquareNeo',
                          )),
                      onPressed: () {
                        exBox.put('todayAlarm', false);
                        exBox.put('todayWakeUpCheck', false);
                        exBox.put('todayWakeUpHelp', false);

                        exBox.put('isGuiding', false);
                        exBox.put('subPathIndex', 0);
                        exBox.put('nextRouteType', 3);

                        exBox.delete('route');

                        Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Home()),
                        );
                      },
                      child: Text('안내 종료')),
                  const SizedBox(width: 30),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          fixedSize: Size(150, 50),
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'NanumSquareNeo',
                          )),
                      onPressed: () {
                        if (subPathIndex + 1 < route.length) {
                          exBox.put('isGuiding', true);
                          exBox.put('subPathIndex', subPathIndex + 1);
                          exBox.put('nextRouteType', route[subPathIndex + 1]["trafficType"]);
                        } else {
                          exBox.put('isGuiding', false);
                          exBox.put('subPathIndex', 0);
                          exBox.put('nextRouteType', 3);
                          exBox.delete('route');
                        }
                        Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Home()),
                        );
                      },
                      child: Text('다음 경로')),
                ]),
                SizedBox(
                  height: 20,
                ),
                Center(
                  child:
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[800],
                          fixedSize: Size(200, 50),
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 20, fontFamily: 'NanumSquareNeo',
                          )
                      ),
                      onPressed: () {
                        getJSONData().then((value) {
                          route = exBox.get('route', defaultValue: []);
                          departureTime = exBox.get('departureTime', defaultValue: DateTime.now().add(Duration(hours: 24)));
                          duration = departureTime.difference(DateTime.now());
                          if (duration.inSeconds < 0) duration = const Duration(seconds: 0);

                          exBox.put('isGuiding', true);
                          exBox.put('subPathIndex', 0);
                          exBox.put('nextRouteType', route[0]["trafficType"]);
                          Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Home()),);
                        });

                      },
                      child: Text('택시 경로 안내')),
                )
              ],
            ))));
  }

  Icon _transportIcon(int index) {
    if (index > -1 && index < route.length) {
      int transportType = route[index]["trafficType"];
      if (transportType == 1) {
        return Icon(Icons.directions_subway, color: TransportColors.subway[route[index]["lane"][0]["subwayCode"]]);
      } else if (transportType == 2) {
        return Icon(Icons.directions_bus, color: TransportColors.bus[route[index]["lane"][0]["type"]]);
      } else if (transportType == 3) {
        if (index == 0) {
          return const Icon(Icons.directions_walk, color: Colors.white70);
        }
        return const Icon(Icons.stop_outlined, color: Colors.white70);
      } else if (transportType == 4) {
        return const Icon(Icons.stop_outlined, color: Colors.white70);
      } else if (transportType == 5) {
        return const Icon(Icons.local_taxi, color: Colors.orangeAccent);
      }
    }

    return const Icon(Icons.directions_walk, color: Colors.white70);
  }

  Text _transportName(int index) {
    if (index > -1 && index < route.length) {

      int transportType = route[index]["trafficType"];

      if (transportType == 1){
        return Text('${route[index]["lane"][0]["name"]}', style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontFamily: 'NanumSquareNeo',
        ));
      }
      else if (transportType == 2){
        return Text('${route[index]["lane"][0]["busNo"]}' , style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontFamily: 'NanumSquareNeo',
        ));
      }
      else if (transportType == 3){
        if (index == 0){
          return const Text('도보' , style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontFamily: 'NanumSquareNeo',
          ));
        }else{
          return const Text('하차' , style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontFamily: 'NanumSquareNeo',
          ));
        }
      }
      else if (transportType == 4){
        return const Text('하차' , style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontFamily: 'NanumSquareNeo',
        ));
      }
      else if (transportType == 5){
        return const Text('택시 승차' , style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontFamily: 'NanumSquareNeo',
        ));
      }
    }

    return const Text('도보',  style: TextStyle(
      color: Colors.white,
      fontSize: 10,
      fontFamily: 'NanumSquareNeo',
    ));
  }

  Future<void> findCurrentStation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    int stationCount = route[subPathIndex]["stationCount"];

    for (int i = 0; i < stationCount; i++) {
      bool lat = (position.latitude <= double.parse(stations[i]["y"]) && position.latitude > double.parse(stations[i + 1]["y"])) || (position.latitude < double.parse(stations[i + 1]["y"]) && position.latitude >= double.parse
        (stations[i]["y"]));
      bool lon = (position.longitude <= double.parse(stations[i]["x"]) && position.longitude > double.parse(stations[i + 1]["x"])) || (position.longitude < double.parse(stations[i + 1]["x"]) && position.longitude >= double.parse
        (stations[i]["x"]));


      if (lat && lon) {

        currentStation = i;

        return;
      }
    }

    var _distanceInMeters = await Geolocator.distanceBetween(
        double.parse(stations[route[subPathIndex]["stationCount"]]["y"]),
      double.parse(stations[route[subPathIndex]["stationCount"]]["x"]),
      position.latitude,
      position.longitude,
    );

    if (_distanceInMeters < 200){
      exBox.put('isGuiding', true);
      exBox.put('subPathIndex', subPathIndex + 1);
      exBox.put('nextRouteType', route[subPathIndex + 1]["trafficType"]);

      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    }

    return;
  }

  Future<Position?> getLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    return position;
  }

  Future<String?> getJSONData() async {

    Future<Position?> position = getLocation();
    if (mounted) setState(() {});
    position?.then((data) async {

      // TODO: Get data from server!
      // var url = 'http://도메인주소/route/getLastTimeAndPath?startX=${data?.longitude}&startY=${data?.latitude}&endX=$x&endY=$y&time=${DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now())}';
      // var response = await http.get(Uri.parse(url), headers: {"Authorization": ""});

      // var response = await rootBundle.loadString('json/response.json');

      var response = await rootBundle.loadString('assets/json/response_taxi.json').then((response) {
        setState(() {
          route.clear();
          // var dataConvertedToJSON = json.decode(response.body);
          var dataConvertedToJSON = json.decode(response);
          departureTime = DateFormat('yyyy-MM-ddTHH:mm:ss').parse(dataConvertedToJSON["departureTime"]);
          duration = departureTime.difference(DateTime.now());
          if (duration.inSeconds > 0) {
            // TODO: set _setDepartureTimeData
            List result = dataConvertedToJSON["pathInfo"]["subPath"];
            route.addAll(result);
            exBox.put('route', route);  // TODO: test hive
          }else{
            duration = const Duration(seconds: 0);
          }
        });

      });

      // return response.body;
      return response;
    });

    return "";
  }
}