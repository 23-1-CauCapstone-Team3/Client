import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:last_transport/app/data/theme_data.dart';
import 'package:last_transport/app/data/data.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import '../../data/alarmInfoDB.dart';
import '../../data/models/alarm_info.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({Key? key}) : super(key: key);

  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  String destination = '집'; //TODO: defaultLocation
  bool todayAlarm = false;
  bool todayWakeUpCheck = false;
  bool todayWakeUpHelp = false;

  /// [S] 출발 시간 타이머 관련 변수 및 method
  DateTime departureTime =
      DateTime.now().add(Duration(seconds: 10)); //TODO: get from server
  Timer? _timer;
  bool _flagTimer = false;
  Duration duration = const Duration(seconds: 1);

  void _startTimer() {
    if (_flagTimer == false) {
      setState(() => _flagTimer = true);
      duration = departureTime.difference(DateTime.now());
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        _setCountDown();
      });
    }
  }

  void _stopTimer() {
    setState(() => _timer!.cancel());
  }

  void _setCountDown() {
    const reduceSecondsBy = 1;
    setState(() {
      final seconds = duration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        _timer!.cancel();
      } else {
        duration = Duration(seconds: seconds);
      }
    });
  }
  /// [E] 출발 시간 타이머 관련 변수 및 method

  /// [S] 새로운 알람 생성 관련 변수 및 method
  DateTime newDate = DateTime.now().add(Duration(days:1));
  String newDestination = '집';  //TODO: 이거 String임?

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
  /// [E] 새로운 알람 생성 관련 변수 및 method

  /// [S] alarmInfo DB 관련 변수 및 method
  AlarmInfoProvider _alarmInfoProvider = AlarmInfoProvider();
  Future<List<AlarmInfo>>? _alarms;
  List<AlarmInfo>? _currentAlarms;

  void loadAlarms() {
    _alarms = _alarmInfoProvider.getDB();
    if (mounted) setState(() {});
  }

  void insertAlarm(DateTime alarmDate, String location){
    _alarmInfoProvider.insert(AlarmInfo(alarmDate: DateFormat('yyyy-MM-dd').format(newDate), location: newDestination));
  }
  /// [E] alarmInfo DB 관련 변수 및 method


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    /// [S] 오늘 막차 알림 정보 가져오기
    // TODO: todayAlarm = ??
    // TODO: if (todayAlarm) { destination = ??; departureTime = ?? }

    if (todayAlarm) {
      _startTimer();
    }

    String strDigits(int n) => n.toString().padLeft(2, '0');
    final hours = strDigits(duration.inHours.remainder(24));
    final minutes = strDigits(duration.inMinutes.remainder(60));
    final seconds = strDigits(duration.inSeconds.remainder(60));

    /// [E] 오늘 막차 알림 정보 가져오기

    loadAlarms();

    return Scaffold(
      backgroundColor: CustomColors.pageBackgroundColor,
      body: Container(
        padding: const EdgeInsets.fromLTRB(15, 50, 15, 0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              /// [S] 오늘 막차 알림 표시
              const Text(
                '오늘 막차 알림',
                style: TextStyle(
                    fontFamily: 'NanumSquareNeo',
                    color: Colors.white,
                    fontSize: 20),
              ),
              SizedBox(height: 5),
              Divider(
                color: Colors.white54,
              ),
              SizedBox(height: 5),

              /// 알람이 있는 경우
              if (todayAlarm) ...[
                const Text(
                  '출발 시간까지',
                  style: TextStyle(
                      fontFamily: 'NanumSquareNeo',
                      color: Colors.white,
                      fontSize: 33),
                ),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 164,
                      child: Text(
                        '$hours:$minutes:$seconds',
                        style: const TextStyle(
                            fontFamily: 'NanumSquareNeo',
                            color: Colors.white,
                            fontSize: 33),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        '남았습니다',
                        style: TextStyle(
                            fontFamily: 'NanumSquareNeo',
                            color: Colors.white,
                            fontSize: 33),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  DateFormat('aa h:mm', 'ko').format(departureTime),
                  style: const TextStyle(
                      fontFamily: 'NanumSquareNeo',
                      color: Colors.white,
                      fontSize: 28),
                ),

                /// 오늘 알람이 없는 경우
              ] else ...[
                const Text(
                  '알림 없음',
                  style: TextStyle(
                      fontFamily: 'NanumSquareNeo',
                      color: Colors.white,
                      fontSize: 40),
                ),
              ],

              /// [E] 오늘 막차 알림 표시
              const SizedBox(height: 20),

              /// [S] 오늘 막차 설정 창
              Container(
                height: 200,
                decoration: BoxDecoration(
                    color: CustomColors.tableBackgroundColor,
                    borderRadius: const BorderRadius.all(Radius.circular(12))),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _TodayAlarmItem0(children: <Widget>[
                        const Text(
                          '목적지',
                          style: TextStyle(
                              fontFamily: 'NanumSquareNeo',
                              color: Colors.white,
                              fontSize: 15),
                        ),
                        CupertinoButton(
                            onPressed: () {}, // TODO
                            child: Text(
                              '$destination >', // TODO - 목적지 변수
                              style: const TextStyle(
                                  fontFamily: 'NanumSquareNeo',
                                  color: Colors.white54,
                                  fontSize: 15),
                            )),
                      ]),
                      _TodayAlarmItem1(children: <Widget>[
                        const Text(
                          '알림',
                          style: TextStyle(
                              fontFamily: 'NanumSquareNeo',
                              color: Colors.white,
                              fontSize: 15),
                        ),
                        CupertinoSwitch(
                          // This bool value toggles the switch.
                          value: todayAlarm,
                          activeColor: CupertinoColors.activeGreen,
                          onChanged: (bool? value) {
                            // This is called when the user toggles the switch.
                            setState(() {
                              todayAlarm = value ?? false;
                            });
                            if (todayAlarm) {
                              _startTimer();
                            } else {
                              _stopTimer();
                            }
                          },
                        ),
                      ]),
                      _TodayAlarmItem1(children: <Widget>[
                        const Text(
                          '기상 체크',
                          style: TextStyle(
                              fontFamily: 'NanumSquareNeo',
                              color: Colors.white,
                              fontSize: 15),
                        ),
                        CupertinoSwitch(
                          // This bool value toggles the switch.
                          value: todayWakeUpCheck,
                          activeColor: CupertinoColors.activeGreen,
                          onChanged: (bool? value) {
                            // This is called when the user toggles the switch.
                            setState(() {
                              if (todayWakeUpCheck || todayAlarm) {
                                todayWakeUpCheck = value ?? false;
                                //TODO: if (todayWakeUpCheck) {기상 체크 기능 켜기}
                              }
                            });
                          },
                        ),
                      ]),
                      _TodayAlarmItem1(children: <Widget>[
                        const Text(
                          '기상 도움 요청',
                          style: TextStyle(
                              fontFamily: 'NanumSquareNeo',
                              color: Colors.white,
                              fontSize: 15),
                        ),
                        CupertinoSwitch(
                          // This bool value toggles the switch.
                          value: todayWakeUpHelp,
                          activeColor: CupertinoColors.activeGreen,
                          onChanged: (bool? value) {
                            // This is called when the user toggles the switch.
                            setState(() {
                              if (todayWakeUpHelp || todayAlarm) {
                                todayWakeUpHelp = value ?? false;
                                //TODO: if (todayWakeUpHelp) {기상 도움 요청 기능 켜기}
                              }
                            });
                          },
                        ),
                      ]),
                    ],
                  ),
                ),
              ),

              /// [E] 오늘 막차 설정 창
              const SizedBox(height: 20),

              /// [S] 기타 일림 view
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <
                  Widget>[
                const Text(
                  '기타',
                  style: TextStyle(
                      fontFamily: 'NanumSquareNeo',
                      color: Colors.white,
                      fontSize: 20),
                ),
                TextButton(
                  onPressed: () {
                    //TODO: insert new Alarm
                    setState(() {
                      newDate = DateTime.now().add(Duration(days: 1));
                      newDestination = '집';
                    });
                    showModalBottomSheet<void>(
                      backgroundColor: CustomColors.sheetBackgroundColor,
                      context: context,
                      builder: (BuildContext context) {
                        return SizedBox(
                          child: Align(
                            alignment: Alignment(0.0, -0.9),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        style: TextButton.styleFrom(
                                          minimumSize: Size.zero,
                                          padding: EdgeInsets.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          '  취소',
                                          style: TextStyle(
                                              fontFamily: 'NanumSquareNeo',
                                              color: Colors.amber[800],
                                              fontSize: 20),
                                        ),
                                      ),
                                      const Text(
                                        '막차 알림 추가',
                                        style: TextStyle(
                                            fontFamily: 'NanumSquareNeo',
                                            color: Colors.white,
                                            fontSize: 20),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // TODO: insert new alarm
                                          if (newDate.difference(DateTime.now()).inSeconds > 0) {
                                            insertAlarm(newDate, newDestination);
                                          }
                                          setState(() => loadAlarms());
                                          Navigator.pop(context);
                                        },
                                        style: TextButton.styleFrom(
                                          minimumSize: Size.zero,
                                          padding: EdgeInsets.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          '저장  ',
                                          style: TextStyle(
                                              fontFamily: 'NanumSquareNeo',
                                              color: Colors.amber[800],
                                              fontSize: 20),
                                        ),
                                      ),
                                    ]),
                                const SizedBox(height: 20),
                                Container(
                                  height: 100,
                                  width: 340,
                                  decoration: BoxDecoration(
                                      color: CustomColors.tableBackgroundColor,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(12))),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        _TodayAlarmItem0(children: <Widget>[
                                          const Text(
                                            '날짜',
                                            style: TextStyle(
                                                fontFamily: 'NanumSquareNeo',
                                                color: Colors.white,
                                                fontSize: 15),
                                          ),
                                          CupertinoButton(
                                            onPressed: () => _showDialog(
                                              CupertinoDatePicker(
                                                initialDateTime: newDate,
                                                mode: CupertinoDatePickerMode.date,
                                                use24hFormat: true,
                                                // This is called when the user changes the date.
                                                onDateTimeChanged: (DateTime date) {
                                                  setState(() => newDate = date);
                                                },
                                              ),
                                            ),
                                            // In this example, the date is formatted manually. You can
                                            // use the intl package to format the value based on the
                                            // user's locale settings.
                                            child: Text(
                                              DateFormat('yyyy.MM.dd (EE) >', 'ko').format(newDate),
                                              style: const TextStyle(
                                                  fontFamily:
                                                  'NanumSquareNeo',
                                                  color: Colors.white54,
                                                  fontSize: 15
                                              ),
                                            ),
                                          ),
                                        ]),
                                        _TodayAlarmItem1(children: <Widget>[
                                          const Text(
                                            '목적지',
                                            style: TextStyle(
                                                fontFamily: 'NanumSquareNeo',
                                                color: Colors.white,
                                                fontSize: 15),
                                          ),
                                          CupertinoButton(
                                              onPressed: () {}, // TODO
                                              child: Text(
                                                '$newDestination >',
                                                // TODO - 목적지 변수
                                                style: const TextStyle(
                                                    fontFamily:
                                                        'NanumSquareNeo',
                                                    color: Colors.white54,
                                                    fontSize: 15),
                                              )),
                                        ]),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    '+',
                    style: TextStyle(
                        fontFamily: 'NanumSquareNeo',
                        color: Colors.amber[800],
                        fontSize: 20),
                  ),
                )
              ]),
              const SizedBox(height: 5),
              const Divider(
                color: Colors.white54,
              ),
              FutureBuilder<List<AlarmInfo>>(
                future: _alarms,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _currentAlarms = snapshot.data;
                    return ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 0),
                        children: snapshot.data!.map<Widget>((alarm) {
                          return Container(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                DateFormat('yyyy.MM.dd (EE)', 'ko')
                                    .format(DateFormat('yyyy-MM-dd').parse(alarm.alarmDate)),
                                style: TextStyle(
                                    color: Colors.white54,
                                    fontFamily: 'NanumSquareNeo',
                                    fontSize: 30),
                              ),
                              SizedBox(height: 10),
                              Text(
                                '목적지',
                                style: TextStyle(
                                    color: Colors.white54,
                                    fontFamily: 'NanumSquareNeo',
                                    fontSize: 20),
                              ),
                              Divider(
                                color: Colors.white54,
                              ),
                            ],
                          ));
                        }).toList());
                  }
                  return Center(
                    child: Text(
                      '알림 없음',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              )

              /// [E] 기타 일림 view
            ],
          ),
        ),
      ),
    );
  }
}


// This class simply decorates a row of widgets.
class _TodayAlarmItem1 extends StatelessWidget {
  const _TodayAlarmItem1({required this.children});

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

class _TodayAlarmItem0 extends StatelessWidget {
  const _TodayAlarmItem0({required this.children});

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
