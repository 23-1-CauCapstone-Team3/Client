import 'dart:async';

import 'package:flutter/material.dart';
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

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _setCountDown();
    });
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

    if (subPathIndex+1 < route.length){
      departureTime = DateFormat('yyyy-MM-ddTHH:mm:ss').parse(route[subPathIndex+1]["lane"][0]["departureTime"]);
      duration = departureTime.difference(DateTime.now());
    }
    else{
      departureTime = DateTime.now();
      duration = departureTime.difference(DateTime.now());
    }

    if (0 <= subPathIndex && subPathIndex < route.length){
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
    }
    else{
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



    _startTimer();
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
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(top: 0),
                  itemCount: route.length - 2,
                  itemBuilder: (context, index) {
                    return Align(
                        alignment: Alignment.centerLeft,
                        child: Row(children: [
                          SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            width: 30,
                            child: _transportIcon(index+1),
                          ),
                          SizedBox(
                            width: 60,
                            child: _transportName(index+1),
                          ),
                          SizedBox(
                            width: 30,
                          ),
                          SizedBox(
                            height: 20,
                            child:
                            Text(
                              '${route[index + 1]["startName"]}',
                              style: const TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 20),
                            ),
                          ),
                        ]));
                  },
                ),
              ),

              Divider(
                color: Colors.white54,
              ),
              SizedBox(height: 5),
              Text(
                '현재 경로',
                style: const TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 20),
              ),
              SizedBox(height: 5),
              Divider(
                color: Colors.white54,
              ),
              // Row(
              //   children: <Widget>[
              //     SizedBox(
              //       width: 164,
              //       child: Text(
              //         '$hours:$minutes:$seconds', // TODO: '$hours:$minutes:$seconds',
              //         style: const TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 33),
              //       ),
              //     ),
              //     const Expanded(
              //       child: Text(
              //         '남았습니다',
              //         style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 33),
              //       ),
              //     )
              //   ],
              // ),
              // SizedBox(height: 20),
              //
              if (route[subPathIndex+1]['trafficType'] == 1) ...[
                // 다음 대중교통: 지하철
                Text(
                  '${route[1]["startName"]}역으로 이동 후',
                  style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 20),
                ),
                SizedBox(height: 5),
                Text(
                  '${route[subPathIndex+1]["lane"][0]["name"]} 탑승',
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
              ] else if (route[subPathIndex+1]['trafficType'] == 2) ...[
                // 다음 대중교통: 버스
                Text(
                  '${route[subPathIndex+1]["startName"]} 정류장 이동',
                  style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 20),
                ),
                SizedBox(height: 5),
                Text(
                  '${route[subPathIndex+1]["lane"][0]["busNo"]} 버스 탑승',
                  style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 20),
                ),
              ] else ...[
                // 다음 대중교통: 택시
                // TODO
              ],
              SizedBox(height: 5),
              Divider(
                color: Colors.white54,
              ),

              SizedBox(height: 10),

              Center(
                  child: SizedBox(
                height: 300,
                width: 400,
                child: NaverMap(
                  onMapCreated: onMapCreated,
                  mapType: _mapType,
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
                  initialCameraPosition: CameraPosition(target: LatLng((route[0]["startY"] + route[0]["endY"]) / 2, (route[0]["startX"] + route[0]["endX"]) / 2)),
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()),);
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
                      if (subPathIndex + 1 < route.length){
                        exBox.put('isGuiding', true);
                        exBox.put('subPathIndex', subPathIndex+1);
                        exBox.put('nextRouteType', route[subPathIndex+1]["trafficType"]);
                      }
                      else{
                        exBox.put('isGuiding', false);
                        exBox.put('subPathIndex', 0);
                        exBox.put('nextRouteType', 3);
                        exBox.delete('route');
                      }
                      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()),);},
                    child: Text('다음 경로')),
              ])
            ],
          )
          )));
  }

  void onMapCreated(NaverMapController controller) {
    if (_controller.isCompleted) _controller = Completer();

    _controller.complete(controller);
  }

  Icon _transportIcon(int index) {
    int transportType = route[index]["trafficType"];
    if (transportType == 1){
      return Icon(Icons.directions_subway, color: TransportColors.subway[route[index]["lane"][0]["subwayCode"]]);
    }else if (transportType == 2){
      return Icon(Icons.directions_bus, color: TransportColors.bus[route[index]["lane"][0]["type"]]);
    }else if (transportType == 3){
      return const Icon(Icons.stop_outlined, color: Colors.white70);
    }else if (transportType == 4){
      return const Icon(Icons.stop_outlined, color: Colors.white70);
    }else if (transportType == 5){
      return const Icon(Icons.local_taxi, color: Colors.orangeAccent);
    }

    return const Icon(Icons.circle_outlined, color: Colors.white70);
  }

  Text _transportName(int index) {
    int transportType = route[index]["trafficType"];
    if (transportType == 1){
      return Text('${route[index]["lane"][0]["name"]}', style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontFamily: 'NanumSquareNeo',
      ));
    }else if (transportType == 2){
      return Text('${route[index]["lane"][0]["busNo"]}' , style: const TextStyle(
      color: Colors.white,
          fontSize: 10,
          fontFamily: 'NanumSquareNeo',
      ));
    }else if (transportType == 3){
      return const Text('하차' , style: TextStyle(
    color: Colors.white,
    fontSize: 10,
    fontFamily: 'NanumSquareNeo',
    ));
    }else if (transportType == 4){
      return const Text('하차' , style: TextStyle(
    color: Colors.white,
    fontSize: 10,
    fontFamily: 'NanumSquareNeo',
    ));
    }else if (transportType == 5){
      return const Text('택시 승차' , style: TextStyle(
    color: Colors.white,
    fontSize: 10,
    fontFamily: 'NanumSquareNeo',
    ));
    }

    return const Text('하차',  style: TextStyle(
      color: Colors.white,
      fontSize: 10,
      fontFamily: 'NanumSquareNeo',
    ));
  }

// Future<String?> getBusLefted() async {
// }
}

//   Future<String?> getJSONData() async {
//
//     // TODO: Get data from server!
//     var url = 'http://ws.bus.go.kr/api/rest/arrive/getArrInfoByRoute?serviceKey=	LS3h90y1uDhV90A73H17ZV%2FSv4W557ZwgHs9A3tFBeeuTqHF1ZX4R%2BNeo2%2FC4kjN6AwzRacIx%2FafR7%2FILwPNDw%3D%3D&stId=&busRouteId=&ord=';
//     // var response = await http.get(Uri.parse(url), headers: {"Authorization": ""});
//
//     // var response = await rootBundle.loadString('json/response.json');
//
//     var response = await rootBundle.loadString('assets/json/response.json').then((response) {
//       setState(() {
//         route.clear();
//         // var dataConvertedToJSON = json.decode(response.body);
//         var dataConvertedToJSON = json.decode(response);
//         departureTime = DateFormat('yyyy-MM-ddTHH:mm:ss').parse(dataConvertedToJSON["departureTime"]);
//         duration = departureTime.difference(DateTime.now());
//         // TODO: set _setDepartureTimeData
//         List result = dataConvertedToJSON["pathInfo"]["subPath"];
//         route.addAll(result);
//         exBox.put('route', route);  // TODO: test hive
//         exBox.put('departureTime', departureTime);
//       });
//
//     });
//
//     // return response.body;
//     return response;
// }
