import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../data/locationInfoDB.dart';
import '../../data/models/location_info.dart';
import '../../data/theme_data.dart';

class MyLocationPage extends StatefulWidget {
  const MyLocationPage({Key? key}) : super(key: key);

  @override
  _MyLocationPageState createState() => _MyLocationPageState();
}

class _MyLocationPageState extends State<MyLocationPage> {
  /// [S] DB
  final LocationInfoProvider _locationInfoProvider = LocationInfoProvider();
  Future<List<LocationInfo>>? _locations;
  List<LocationInfo>? _currentLocations;

  void loadLocations() {
    _locations = _locationInfoProvider.getDB();
    if (mounted) setState(() {});
  }

  void insertLocation(String location, String address) {
    _locationInfoProvider.insert(LocationInfo(location: location, address: address));
  }

  void updateLocation(LocationInfo locationInfo) {
    _locationInfoProvider.update(locationInfo);
  }

  void deleteLocation(LocationInfo locationInfo) {
    _locationInfoProvider.delete(locationInfo);
  }

  /// [E] DB

  late TextEditingController _textController;
  late TextEditingController _addressTextController;

  String result = '';
  List data = [];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: '');
    _addressTextController = TextEditingController(text: '');
  }

  @override
  Widget build(BuildContext context) {
    loadLocations();

    return Scaffold(
      backgroundColor: CustomColors.pageBackgroundColor,
      body: Container(
        padding: const EdgeInsets.fromLTRB(15, 50, 15, 0),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
              const Text(
                '저장된 장소',
                style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 20),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  '+',
                  style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.amber[800], fontSize: 25),
                ),
                onPressed: () {
                  _textController.clear();
                  String address = '';
                  //TODO: insert new Location
                  showModalBottomSheet<void>(
                    isScrollControlled: true,
                    backgroundColor: CustomColors.sheetBackgroundColor,
                    context: context,
                    builder: (BuildContext context) {
                      // DateTime newDate = DateTime.now().add(Duration(days: 1));
                      // String newDestination = '집';
                      return _addNewLocation(address);
                    },
                  );
                },
              )
            ]),
            const SizedBox(height: 16),
            const Divider(
              color: Colors.white54,
              height: 0,
            ),
            _buildFutureBuilder()
          ]),
        ),
      ),
    );
  }

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => Container(
              height: 216,
              padding: const EdgeInsets.only(top: 6.0),
              // The Bottom margin is provided to align the popup above the system
              // navigation bar.
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              // Provide a background color for the popup.
              color: CupertinoColors.systemBackground.resolveFrom(context),
              // Use a SafeArea widget to avoid system overlaps.
              child: SafeArea(
                top: false,
                child: child,
              ),
            ));
  }

  StatefulBuilder _addNewLocation(String address) {
    return StatefulBuilder(
        builder: (BuildContext context, setState) => SizedBox(
              height: MediaQuery.of(context).size.height * 0.92,
              child: Align(
                alignment: Alignment(0.0, -0.9),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          '  취소',
                          style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.amber[800], fontSize: 20),
                        ),
                      ),
                      const Text(
                        '내 장소 등록',
                        style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 20),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: insert new alarm
                          insertLocation(_textController.text, address);
                          setState(() => loadLocations());
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          '저장  ',
                          style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.amber[800], fontSize: 20),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    Container(
                      height: 100,
                      width: 340,
                      decoration: BoxDecoration(color: CustomColors.tableBackgroundColor, borderRadius: const BorderRadius.all(Radius.circular(12))),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            _LocationItem0(children: <Widget>[
                              const Text(
                                '레이블',
                                style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 15),
                              ),
                              SizedBox(
                                width: 200,
                                child: TextField(
                                  textAlign: TextAlign.right,
                                  cursorColor: CustomColors.tableBackgroundColor,
                                  controller: _textController,
                                  decoration: const InputDecoration(
                                    hintText: '장소 이름',
                                    hintStyle: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white54, fontSize: 15),
                                    border: InputBorder.none,
                                  ),
                                  style: const TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 15),
                                ),
                              )

                              // CupertinoButton(
                              //   onPressed: () => _showDialog(
                              //     CupertinoDatePicker(
                              //       initialDateTime: newDate,
                              //       mode:
                              //           CupertinoDatePickerMode
                              //               .date,
                              //       use24hFormat: true,
                              //       // This is called when the user changes the date.
                              //       onDateTimeChanged:
                              //           (DateTime date) {
                              //         setState(() =>
                              //             newDate = date);
                              //       },
                              //     ),
                              //   ),
                              //   // In this example, the date is formatted manually. You can
                              //   // use the intl package to format the value based on the
                              //   // user's locale settings.
                              //   child: Text(
                              //       // TODO
                              //       'text'
                              //       // DateFormat(
                              //       //         'yyyy.MM.dd (EE) >',
                              //       //         'ko')
                              //       //     .format(newDate),
                              //       // style: const TextStyle(
                              //       //     fontFamily:
                              //       //         'NanumSquareNeo',
                              //       //     color: Colors.white54,
                              //       //     fontSize: 15),
                              //       ),
                              // ),
                            ]),
                            _LocationItem1(children: <Widget>[
                              const Text(
                                '주소',
                                style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 15),
                              ),
                              CupertinoButton(
                                  onPressed: () {
                                    showModalBottomSheet<void>(
                                      isScrollControlled: true,
                                      backgroundColor: CustomColors.sheetBackgroundColor,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return _searchLocation();
                                      },
                                    );
                                  }, // TODO
                                  child: Text(
                                    address,
                                    // TODO - 주소 변수
                                    style: const TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white54, fontSize: 15),
                                  )),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }

  StatefulBuilder _searchLocation() {
    return StatefulBuilder(
        builder: (BuildContext context, setState) => SizedBox(
            height: MediaQuery.of(context).size.height * 0.92,
            child: Align(
                alignment: const Alignment(0.0, -0.9),
                child: Column(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                    Text(
                      '  취소',
                      style: TextStyle(fontFamily: 'NanumSquareNeo', color: CustomColors.sheetBackgroundColor, fontSize: 20),
                    ),
                    const Text(
                      '위치',
                      style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 20),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        '취소  ',
                        style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.amber[800], fontSize: 20),
                      ),
                    ),
                  ]),
                  const SizedBox(
                    height: 25,
                  ),
                  SizedBox(
                    width: 340,
                    child: CupertinoSearchTextField(
                      controller: _addressTextController,
                      placeholder: 'Search',
                      style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 15),
                    ),
                  ),
                  // TODO: search results
                  Center(
                    child: data.length == 0
                        ? const SizedBox(
                            height: 25,
                          )
                        : ListView.builder(
                            itemBuilder: (context, index) {
                              return Card(
                                child: Column(
                                  children: [
                                    Text(data[index]['place_name'].toString()),
                                    Text(data[index]['road_address_name'].toString()),
                                  ],
                                ),
                              );
                            },
                            itemCount: data.length,
                          ),
                  ),
                ]))));
  }

  FutureBuilder<List<LocationInfo>> _buildFutureBuilder() {
    return FutureBuilder<List<LocationInfo>>(
      future: _locations,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _currentLocations = snapshot.data;
          return ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 0),
              children: snapshot.data!.map<Widget>((location) {
                return InkWell(
                    onTap: () {
                      //   showModalBottomSheet<void>(
                      // isScrollControlled: true,
                      //     backgroundColor:
                      //         CustomColors.sheetBackgroundColor,
                      //     context: context,
                      //     builder: (BuildContext context) {
                      //       DateTime newDate =
                      //           DateFormat('yyyy-MM-dd')
                      //               .parse(alarm.alarmDate);
                      //       String newDestination = alarm.location;
                      //       return StatefulBuilder(
                      //           builder:
                      //               (BuildContext context,
                      //                       setState) =>
                      //                   SizedBox(
                      // height:
                      // MediaQuery.of(context).size.height * 0.92,
                      //                     child: Align(
                      //                       alignment:
                      //                           Alignment(0.0, -0.9),
                      //                       child: Column(
                      //                         mainAxisAlignment:
                      //                             MainAxisAlignment
                      //                                 .start,
                      //                         mainAxisSize:
                      //                             MainAxisSize.min,
                      //                         children: <Widget>[
                      //                           Row(
                      //                               mainAxisAlignment:
                      //                                   MainAxisAlignment
                      //                                       .spaceBetween,
                      //                               children: <
                      //                                   Widget>[
                      //                                 TextButton(
                      //                                   onPressed:
                      //                                       () {
                      //                                     Navigator.pop(
                      //                                         context);
                      //                                   },
                      //                                   style: TextButton
                      //                                       .styleFrom(
                      //                                     minimumSize:
                      //                                         Size.zero,
                      //                                     padding:
                      //                                         EdgeInsets
                      //                                             .zero,
                      //                                     tapTargetSize:
                      //                                         MaterialTapTargetSize
                      //                                             .shrinkWrap,
                      //                                   ),
                      //                                   child: Text(
                      //                                     '  취소',
                      //                                     style: TextStyle(
                      //                                         fontFamily:
                      //                                             'NanumSquareNeo',
                      //                                         color: Colors.amber[
                      //                                             800],
                      //                                         fontSize:
                      //                                             20),
                      //                                   ),
                      //                                 ),
                      //                                 const Text(
                      //                                   '막차 알림 편집',
                      //                                   style: TextStyle(
                      //                                       fontFamily:
                      //                                           'NanumSquareNeo',
                      //                                       color: Colors
                      //                                           .white,
                      //                                       fontSize:
                      //                                           20),
                      //                                 ),
                      //                                 TextButton(
                      //                                   onPressed:
                      //                                       () {
                      //                                     // TODO: insert new alarm
                      //                                     if (newDate
                      //                                             .difference(DateTime.now())
                      //                                             .inSeconds >
                      //                                         0) {
                      //                                       updateAlarm(AlarmInfo(
                      //                                           id: alarm
                      //                                               .id,
                      //                                           alarmDate: DateFormat('yyyy-MM-dd').format(
                      //                                               newDate),
                      //                                           location:
                      //                                               newDestination));
                      //                                     }
                      //                                     setState(() =>
                      //                                         loadAlarms());
                      //                                     Navigator.pop(
                      //                                         context);
                      //                                   },
                      //                                   style: TextButton
                      //                                       .styleFrom(
                      //                                     minimumSize:
                      //                                         Size.zero,
                      //                                     padding:
                      //                                         EdgeInsets
                      //                                             .zero,
                      //                                     tapTargetSize:
                      //                                         MaterialTapTargetSize
                      //                                             .shrinkWrap,
                      //                                   ),
                      //                                   child: Text(
                      //                                     '저장  ',
                      //                                     style: TextStyle(
                      //                                         fontFamily:
                      //                                             'NanumSquareNeo',
                      //                                         color: Colors.amber[
                      //                                             800],
                      //                                         fontSize:
                      //                                             20),
                      //                                   ),
                      //                                 ),
                      //                               ]),
                      //                           const SizedBox(
                      //                               height: 20),
                      //                           Container(
                      //                             height: 100,
                      //                             width: 340,
                      //                             decoration: BoxDecoration(
                      //                                 color: CustomColors
                      //                                     .tableBackgroundColor,
                      //                                 borderRadius:
                      //                                     const BorderRadius
                      //                                             .all(
                      //                                         Radius.circular(
                      //                                             12))),
                      //                             child: Center(
                      //                               child: Column(
                      //                                 mainAxisAlignment:
                      //                                     MainAxisAlignment
                      //                                         .center,
                      //                                 children: <
                      //                                     Widget>[
                      //                                   _TodayAlarmItem0(
                      //                                       children: <
                      //                                           Widget>[
                      //                                         const Text(
                      //                                           '날짜',
                      //                                           style: TextStyle(
                      //                                               fontFamily: 'NanumSquareNeo',
                      //                                               color: Colors.white,
                      //                                               fontSize: 15),
                      //                                         ),
                      //                                         CupertinoButton(
                      //                                           onPressed: () =>
                      //                                               _showDialog(
                      //                                             CupertinoDatePicker(
                      //                                               initialDateTime: newDate,
                      //                                               mode: CupertinoDatePickerMode.date,
                      //                                               use24hFormat: true,
                      //                                               // This is called when the user changes the date.
                      //                                               onDateTimeChanged: (DateTime date) {
                      //                                                 setState(() => newDate = date);
                      //                                               },
                      //                                             ),
                      //                                           ),
                      //                                           // In this example, the date is formatted manually. You can
                      //                                           // use the intl package to format the value based on the
                      //                                           // user's locale settings.
                      //                                           child:
                      //                                               Text(
                      //                                             DateFormat('yyyy.MM.dd (EE) >', 'ko').format(newDate),
                      //                                             style: const TextStyle(
                      //                                                 fontFamily: 'NanumSquareNeo',
                      //                                                 color: Colors.white54,
                      //                                                 fontSize: 15),
                      //                                           ),
                      //                                         ),
                      //                                       ]),
                      //                                   _TodayAlarmItem1(
                      //                                       children: <
                      //                                           Widget>[
                      //                                         const Text(
                      //                                           '목적지',
                      //                                           style: TextStyle(
                      //                                               fontFamily: 'NanumSquareNeo',
                      //                                               color: Colors.white,
                      //                                               fontSize: 15),
                      //                                         ),
                      //                                         CupertinoButton(
                      //                                             onPressed:
                      //                                                 () {},
                      //                                             // TODO
                      //                                             child:
                      //                                                 Text(
                      //                                               '$newDestination >',
                      //                                               // TODO - 목적지 변수
                      //                                               style: const TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white54, fontSize: 15),
                      //                                             )),
                      //                                       ]),
                      //                                 ],
                      //                               ),
                      //                             ),
                      //                           ),
                      //                           const SizedBox(
                      //                               height: 20),
                      //                           Container(
                      //                             height: 50,
                      //                             width: 340,
                      //                             decoration: BoxDecoration(
                      //                                 color: CustomColors
                      //                                     .tableBackgroundColor,
                      //                                 borderRadius:
                      //                                     const BorderRadius
                      //                                             .all(
                      //                                         Radius.circular(
                      //                                             12))),
                      //                             child: TextButton(
                      //                               onPressed: () {
                      //                                 deleteAlarm(
                      //                                     alarm);
                      //                                 setState(() =>
                      //                                     loadAlarms());
                      //                                 Navigator.pop(
                      //                                     context);
                      //                               },
                      //                               child: const Text(
                      //                                 '알림 삭제',
                      //                                 style: TextStyle(
                      //                                     fontFamily:
                      //                                         'NanumSquareNeo',
                      //                                     color: Colors
                      //                                         .red,
                      //                                     fontSize:
                      //                                         15),
                      //                               ),
                      //                             ),
                      //                           ),
                      //                         ],
                      //                       ),
                      //                     ),
                      //                   ));
                      //     },
                      //   );
                    },
                    child: Column(children: <Widget>[
                      SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Image.asset(
                            'assets/img/location.png',
                            width: 25,
                            height: 25,
                            fit: BoxFit.fill,
                          ),
                          SizedBox(width: 10),
                          SizedBox(
                            width: 50,
                            height: 25,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                location.location,
                                style: const TextStyle(color: Colors.white54, fontFamily: 'NanumSquareNeo', fontSize: 18),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 235,
                            height: 25,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                location.address,
                                style: const TextStyle(color: Colors.white54, fontFamily: 'NanumSquareNeo', fontSize: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(
                        color: Colors.white54,
                        thickness: 0,
                        height: 0,
                      ),
                    ]));
              }).toList());
        }
        return const Center(
          child: Text(
            '내 장소 없음',
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }
}

// This class simply decorates a row of widgets.
class _LocationItem1 extends StatelessWidget {
  const _LocationItem1({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: CupertinoColors.inactiveGray,
              width: 0.0,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: children,
          ),
        ),
      ),
    );
  }
}

class _LocationItem0 extends StatelessWidget {
  const _LocationItem0({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: DecoratedBox(
        decoration: const BoxDecoration(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: children,
          ),
        ),
      ),
    );
  }
}

class SearchTextField extends StatelessWidget {
  const SearchTextField({
    super.key,
    required this.fieldValue,
  });

  final ValueChanged<String> fieldValue;

  @override
  Widget build(BuildContext context) {
    return CupertinoSearchTextField(
      onChanged: (String value) {
        fieldValue('The text has changed to: $value');
      },
      onSubmitted: (String value) {
        fieldValue('Submitted text: $value');
      },
    );
  }
}
