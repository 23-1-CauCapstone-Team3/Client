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

class WalkPage extends StatefulWidget {
  const WalkPage({Key? key}) : super(key: key);

  @override
  _WalkPage createState() => _WalkPage();
}

class _WalkPage extends State<WalkPage> {
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

  late List route = []; // Hive
  late DateTime departureTime = DateTime.now();
  late Duration duration = departureTime.difference(DateTime.now());
  Timer? _timer;

  late int subPathIndex = 0; // Hive
  late int currentRouteType = 3; // Hive

  void _startTimer() {
    duration = departureTime.difference(DateTime.now());

    if (duration.inSeconds > 0) {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        _setCountDown();
      });
    } else {
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

    if (subPathIndex + 1 < route.length && route[subPathIndex + 1]["trafficType"] != 5) {
      departureTime = DateFormat('yyyy-MM-ddTHH:mm:ss').parse(route[subPathIndex + 1]["lane"][0]["departureTime"]);
      duration = departureTime.difference(DateTime.now());

      if (duration.inSeconds < 0) duration = const Duration(seconds: 0);
    } else {
      departureTime = DateTime.now().add(Duration(hours: 24));
      duration = departureTime.difference(DateTime.now());

      if (duration.inSeconds < 0) duration = const Duration(seconds: 0);
    }

    if (0 <= subPathIndex && subPathIndex < route.length) {
      route[subPathIndex]["steps"].forEach((feature) {
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
    } else {
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

    findCurrentStation();

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
                              // height: 20,
                              width: 200,
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
                        child: Text(
                          '${route[route.length - 1]["endName"]}',
                          style: const TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 20),
                        ),
                      ),
                    ])),
                Divider(
                  color: Colors.white54,
                ),
                SizedBox(height: 5),
                if (subPathIndex + 1 < route.length) ...[
                  if (route[subPathIndex + 1]['trafficType'] == 1) ...[
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
                      '${route[subPathIndex + 1]["startName"]}역에서 ${route[subPathIndex + 1]["lane"][0]["name"]} 탑승',
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
                  ] else if (route[subPathIndex + 1]['trafficType'] == 2) ...[
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
                      '${route[subPathIndex + 1]["startName"]} 정류장에서 ${route[subPathIndex + 1]["lane"][0]["busNo"]} 버스 탑승',
                      style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 20),
                    ),
                    SizedBox(height: 5),
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
                  ] else ...[
                    // 다음 대중교통: 택시
                    // TODO
                  ]
                ],
                SizedBox(height: 10),
                Center(
                    child: SizedBox(
                  height: 300,
                  width: 400,
                  child: NaverMap(
                    onMapCreated: onMapCreated,
                    mapType: _mapType,
                    locationButtonEnable: true,
                    markers: [
                      Marker(markerId: 'start', position: LatLng(route[subPathIndex]["startY"], route[subPathIndex]["startX"]), width: 30, height: 40),
                      Marker(markerId: 'end', position: LatLng(route[subPathIndex]["endY"], route[subPathIndex]["endX"]), width: 30, height: 40),
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
                    initialCameraPosition: CameraPosition(target: LatLng((route[subPathIndex]["startY"] + route[subPathIndex]["endY"]) / 2, (route[subPathIndex]["startX"] + route[subPathIndex]["endX"]) / 2)),
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

                          exBox.put('todayAlarm', false);
                          exBox.put('todayWakeUpCheck', false);
                          exBox.put('todayWakeUpHelp', false);

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
                        String domain = "e161-58-76-161-56.ngrok-free.app";

                        String x = exBox.get('x', defaultValue: "126.955870181663");
                        String y = exBox.get('y', defaultValue: "37.5038217213134");

                        if (mounted) setState(() {});
                        position?.then((data) async {
                          print('walk_page');
                          print(data);
                          print(x);
                          print(y);

                          /// Use this code when using server.
                          // TODO: Get data from server!
                          var url = 'http://${domain}/route/getLastTimeAndPath?startX=${data?.longitude}&startY=${data?.latitude}&endX=$x&endY=$y&time=${DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now())}';
                          var response = await http.get(Uri.parse(url));

                          /// Use this code when using json file.
                          // var response = await rootBundle.loadString('assets/json/response_taxi.json');

                          setState(() {
                            print('in setState');
                            route.clear();
                            // var dataConvertedToJSON = json.decode(response);          ///  Use this code when using json file.
                            var dataConvertedToJSON = json.decode(response.body);  ///  Use this code when using server.
                            departureTime = DateFormat('yyyy-MM-ddTHH:mm:ss').parse(dataConvertedToJSON["departureTime"]);
                            duration = departureTime.difference(DateTime.now());

                            print(duration.inSeconds);

                            if (duration.inSeconds > 0) {
                              // TODO: set _setDepartureTimeData
                              List result = dataConvertedToJSON["pathInfo"]["subPath"];
                              route.addAll(result);
                              print(route);
                              exBox.put('route', route); // TODO: test hive
                              exBox.put('departureTime', departureTime);
                            } else {
                              duration = const Duration(seconds: 0);
                            }

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
              ],
            ))));
  }

  void onMapCreated(NaverMapController controller) {
    if (_controller.isCompleted) _controller = Completer();

    _controller.complete(controller);
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

      if (transportType == 1) {
        return Text('${route[index]["lane"][0]["name"]}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontFamily: 'NanumSquareNeo',
            ));
      } else if (transportType == 2) {
        return Text('${route[index]["lane"][0]["busNo"]}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontFamily: 'NanumSquareNeo',
            ));
      } else if (transportType == 3) {
        if (index == 0) {
          return const Text('도보',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontFamily: 'NanumSquareNeo',
              ));
        } else {
          return const Text('하차',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontFamily: 'NanumSquareNeo',
              ));
        }
      } else if (transportType == 4) {
        return const Text('하차',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontFamily: 'NanumSquareNeo',
            ));
      } else if (transportType == 5) {
        return const Text('택시 승차',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontFamily: 'NanumSquareNeo',
            ));
      }
    }

    return const Text('도보',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontFamily: 'NanumSquareNeo',
        ));
  }

  Future<void> findCurrentStation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    var _distanceInMeters = await Geolocator.distanceBetween(
      route[subPathIndex]["endY"],
      route[subPathIndex]["endX"],
      position.latitude,
      position.longitude,
    );

    if (_distanceInMeters < 100) {
      if (subPathIndex + 1 < route.length) {
        exBox.put('isGuiding', true);
        exBox.put('subPathIndex', subPathIndex + 1);
        exBox.put('nextRouteType', route[subPathIndex + 1]["trafficType"]);
      } else {
        exBox.put('isGuiding', false);
        exBox.put('subPathIndex', 0);
        exBox.put('nextRouteType', 3);

        exBox.put('todayAlarm', false);
        exBox.put('todayWakeUpCheck', false);
        exBox.put('todayWakeUpHelp', false);

        exBox.delete('route');
      }
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
}
