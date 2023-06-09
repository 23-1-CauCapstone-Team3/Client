import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';

import '../../data/theme_data.dart';
import 'home.dart';

class LockScreenActivityPage extends StatefulWidget {
  const LockScreenActivityPage({Key? key}) : super(key: key);

  @override
  _LockScreenActivityPage createState() => _LockScreenActivityPage();
}

class _LockScreenActivityPage extends State<LockScreenActivityPage> {
  static const MODE_ADD = 0xF1;
  static const MODE_REMOVE = 0xF2;
  static const MODE_NONE = 0xF3;
  int _currentMode = MODE_NONE;

  Completer<NaverMapController> _controller = Completer();
  MapType _mapType = MapType.Basic;

  List<Marker> _markers = [];
  List<LatLng> _coordinates = [];

  void _onMarkerTap(Marker? marker, Map<String, int?>? iconSize) {
    if (_currentMode == MODE_REMOVE && _coordinates.length > 2) {
      setState(() {
        _coordinates.remove(marker!.position);
        _markers.removeWhere((m) => m.markerId == marker.markerId);
      });
    }
  }

  var exBox = Hive.box('box_name');

  late List route; // Hive
  late DateTime departureTime; // Hive
  late Duration duration;
  Timer? _timer;

  void _startTimer() {
    duration = departureTime.difference(DateTime.now());

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _setCountDown();
    });
  }

  void _stopTimer() {
    setState(() {
      _timer?.cancel();
    });
  }

  void _setCountDown() {
    const reduceSecondsBy = 1;
    setState(() {
      final seconds = duration.inSeconds - reduceSecondsBy;
      if (seconds - 1 < 0) {
        duration = const Duration(seconds: 0);
        _timer?.cancel();
      } else {
        duration = Duration(seconds: seconds);
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
    departureTime = exBox.get('departureTime', defaultValue: DateTime.now().add(Duration(hours: 24)));
    duration = departureTime.difference(DateTime.now());

    if (duration.inSeconds < 0) duration = const Duration(seconds: 0);

    if (route.isNotEmpty) {
      route[0]["steps"].forEach((feature) {
        if (feature["geometry"]["type"] == "Point") {
          _coordinates.add(LatLng(feature["geometry"]["coordinates"][1], feature["geometry"]["coordinates"][0]));
        } else {
          feature["geometry"]["coordinates"].forEach((point) {
            _coordinates.add(LatLng(point[1], point[0]));
          });
        }
      });

      _coordinates.forEach((point) {
        _markers.add(Marker(
          markerId: point.json.toString(),
          position: point,
          onMarkerTab: _onMarkerTap,
        ));
      });
    }

    if (duration.inSeconds > 0) {
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    route = exBox.get('route', defaultValue: []);
    departureTime = exBox.get('departureTime', defaultValue: DateTime.now().add(Duration(hours: 24)));
    duration = departureTime.difference(DateTime.now());

    if (duration.inSeconds < 0) duration = const Duration(seconds: 0);

    if (route.isNotEmpty && _coordinates.isEmpty && _markers.isEmpty) {
      route[0]["steps"].forEach((feature) {
        if (feature["geometry"]["type"] == "Point") {
          _coordinates.add(LatLng(feature["geometry"]["coordinates"][1], feature["geometry"]["coordinates"][0]));
        } else {
          feature["geometry"]["coordinates"].forEach((point) {
            _coordinates.add(LatLng(point[1], point[0]));
          });
        }
      });

      _coordinates.forEach((point) {
        _markers.add(Marker(
          markerId: point.json.toString(),
          position: point,
          onMarkerTab: _onMarkerTap,
        ));
      });
    }

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
              if (exBox.get('todayAlarm') == true && exBox.get('departureTime', defaultValue: DateTime.now().add(Duration(hours: 24))).difference(DateTime.now()).compareTo(Duration(minutes: 20)) < 0 && route.isNotEmpty) ...[
                Text(
                  '출발 시각까지',
                  style: const TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 33),
                ),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 164,
                      child: Text(
                        '$hours:$minutes:$seconds', // TODO: '$hours:$minutes:$seconds',
                        style: const TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 33),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        '남았습니다',
                        style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 33),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20),
                if (route[1]["trafficType"] == 1) ...[
                  // 다음 대중교통: 지하철
                  Text(
                    '${route[1]["startName"]}역으로 이동',
                    style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 20),
                  ),
                  SizedBox(height: 5),
                  Divider(
                    color: Colors.white54,
                  ),
                  SizedBox(height: 5),
                  Text(
                    '${route[1]["lane"][0]["name"]} 탑승',
                    style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 18),
                  ),
                  SizedBox(height: 5),
                  Divider(
                    color: Colors.white54,
                  ),
                ] else if (route[1]["trafficType"] == 2) ...[
                  // 다음 대중교통: 버스
                  Text(
                    '${route[1]["startName"]} 정류장 이동',
                    style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 20),
                  ),
                  SizedBox(height: 5),
                  Divider(
                    color: Colors.white54,
                  ),
                  SizedBox(height: 5),
                  Text(
                    '${route[1]["lane"][0]["busNo"]} 버스 탑승',
                    style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 18),
                  ),
                  SizedBox(height: 5),
                  Divider(
                    color: Colors.white54,
                  ),
                ] else ...[
                  // 다음 대중교통: 택시
                  Text(
                    '${route[1]["startName"]}로 이동',
                    style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 20),
                  ),
                  SizedBox(height: 5),
                  Divider(
                    color: Colors.white54,
                  ),
                  SizedBox(height: 5),
                  Text(
                    '택시 탑승',
                    style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 18),
                  ),
                  SizedBox(height: 5),
                  Divider(
                    color: Colors.white54,
                  ),
                ],
                SizedBox(height: 20),
                Center(
                    child: SizedBox(
                  height: 300,
                  width: 400,
                  child: NaverMap(
                    onMapCreated: onMapCreated,
                    mapType: _mapType,
                    locationButtonEnable: true,
                    markers: [
                      Marker(markerId: 'start', position: LatLng(route[0]["startY"], route[0]["startX"]), width: 30, height: 40),
                      Marker(markerId: 'end', position: LatLng(route[0]["endY"], route[0]["endX"]), width: 30, height: 40),
                    ],
                    pathOverlays: {
                      PathOverlay(
                        PathOverlayId('path'),
                        _coordinates,
                        width: 5,
                        color: Colors.orange,
                        outlineColor: Colors.white,
                      )
                    },
                    initialCameraPosition: CameraPosition(target: LatLng((route[0]["startY"] + route[0]["endY"]) / 2, (route[0]["startX"] + route[0]["endX"]) / 2), zoom: 14.0),
                  ),
                )),
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
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'NanumSquareNeo',
                          )),
                      onPressed: () {
                        exBox.put('isGuiding', true);
                        exBox.put('subPathIndex', 0);
                        exBox.put('nextRouteType', route[0]["trafficType"]);
                        Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Home()),
                        );
                      },
                      child: Text('안내 시작')),
                ])
              ] else ...[

                Center(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[800],
                          fixedSize: Size(200, 50),
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'NanumSquareNeo',
                          )),
                      onPressed: () {
                        // TODO: 두번 눌러야 로드 되는 상황 발생 (이유를 모르겠음)

                        Future<Position?> position = getLocation();
                        String domain = "http://52.78.214.66:3000/";

                        String x = exBox.get('x', defaultValue: "126.955870181663");
                        String y = exBox.get('y', defaultValue: "37.5038217213134");

                        if (mounted) setState(() {});
                        position?.then((data) async {

                          print('lock_screen_activity_page');
                          print(data);
                          print(x);
                          print(y);

                          /// Use this code when using server.
                          // TODO: Get data from server!
                          var url = '${domain}taxiRoute/findTaxiPath?startX=${data?.longitude}&startY=${data?.latitude}&endX=$x&endY=$y&time=${DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now())}';
                          var response = await http.get(Uri.parse(url));

                          /// Use this code when using json file.
                          // var response = await rootBundle.loadString('assets/json/response_taxi.json');

                          setState(() {
                            print('in setState');
                            route.clear();
                            // var dataConvertedToJSON = json.decode(response);          //  Use this code when using json file.
                            var dataConvertedToJSON = json.decode(response.body);  //  Use this code when using server.
                            print(dataConvertedToJSON);
                            departureTime = DateFormat('yyyy-MM-ddTHH:mm:ss').parse(dataConvertedToJSON["departureTime"]);
                            duration = departureTime.difference(DateTime.now());

                            print(dataConvertedToJSON["departureTime"]);
                            print(duration.inSeconds);

                            // TODO: set _setDepartureTimeData
                            List result = dataConvertedToJSON["pathInfo"]["subPath"];
                            print(result);
                            route.addAll(result);
                            print(route);
                            exBox.put('route', route); // TODO: test hive
                            exBox.put('departureTime', departureTime);

                            exBox.put('isGuiding', true);
                            exBox.put('subPathIndex', 0);
                            exBox.put('nextRouteType', route[0]["trafficType"]);
                            Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Home()),
                            );
                          });
                        });
                      },
                      child: Text('택시 경로 안내')),
                )
              ]
            ],
          )),
        ));
  }

  void onMapCreated(NaverMapController controller) {
    if (_controller.isCompleted) _controller = Completer();

    _controller.complete(controller);
  }

  Future<Position?> getLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    return position;
  }
}
