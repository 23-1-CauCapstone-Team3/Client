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

  void insertLocation(String location, String address, String x, String y) {
    _locationInfoProvider.insert(LocationInfo(location: location, address: address, x: x, y: y));
  }

  void updateLocation(LocationInfo locationInfo) {
    _locationInfoProvider.update(locationInfo);
  }

  void deleteLocation(int id) {
    _locationInfoProvider.deleteWithID(id);
  }

  /// [E] DB

  late TextEditingController _textController;
  late TextEditingController _addressTextController;

  // late String result;
  late List data;
  late String address;
  late String x;
  late String y;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: '');
    _addressTextController = TextEditingController(text: '');
    // result = '';
    data = [];
    address = '';
    x = '';
    y = '';

    loadLocations();
  }

  @override
  Widget build(BuildContext context) {

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
                  address = '';
                  x = '';
                  y = '';
                  //TODO: insert new Location
                  showModalBottomSheet<void>(
                    isScrollControlled: true,
                    backgroundColor: CustomColors.sheetBackgroundColor,
                    context: context,
                    builder: (BuildContext context) {
                      return _addNewLocation();
                    },
                  ).then((value) {
                    setState(() {});
                  });
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

  StatefulBuilder _addNewLocation() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter bottomState) => SizedBox(
              height: MediaQuery.of(context).size.height * 0.92,
              child: Align(
                alignment: const Alignment(0.0, -0.9),
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
                          // TODO: insert new location
                          insertLocation(_textController.text, address, x, y);
                          bottomState(() {
                            setState(() => loadLocations());
                          });
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
                      // height: 100,
                      height: 200,
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
                            ]),
                            _LocationItem1(children: <Widget>[
                              const Text(
                                '주소',
                                style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 15),
                              ),
                              // TODO: 우측에 생기는 Padding 없애기
                              CupertinoButton(
                                  onPressed: () {
                                    _addressTextController.clear();
                                    data.clear();
                                    // result = '';
                                    showModalBottomSheet<void>(
                                      isScrollControlled: true,
                                      backgroundColor: CustomColors.sheetBackgroundColor,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return _searchLocation();
                                      },
                                    ).then((value) {
                                      bottomState(() {
                                        setState(() {});
                                      });
                                    });
                                  }, // TODO
                                  child: Text(
                                    address,
                                    // TODO - 주소 변수
                                    style: const TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white54, fontSize: 15),
                                  )),
                            ]),
                            _LocationItem1(children: <Widget>[
                              const Text(
                                'x',
                                style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 15),
                              ),
                              // TODO: 우측에 생기는 Padding 없애기
                              SizedBox(
                                  width: 200,
                                  child: Text(
                                    x,
                                    // TODO - 주소 변수
                                    style: const TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white54, fontSize: 15),
                                  )),
                            ]),
                            _LocationItem1(children: <Widget>[
                              const Text(
                                'y',
                                style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 15),
                              ),
                              // TODO: 우측에 생기는 Padding 없애기
                              SizedBox(
                                  width: 200,
                                  child: Text(
                                    y,
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
    ScrollController _scrollController = new ScrollController();

    return StatefulBuilder(
        builder: (BuildContext context, StateSetter bottomState) => SizedBox(
            height: MediaQuery.of(context).size.height * 0.92,
            child: Container(
                padding: const EdgeInsets.fromLTRB(15, 25, 15, 0),
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
                      onChanged: (String value) {
                        getJSONData(value);
                      },
                      onSubmitted: (String value) {
                        getJSONData(value);
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // TODO: search results
                  Expanded(
                    child: data.isEmpty
                        ? const Text(
                            "",
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.center,
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            // physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(top: 0),
                            itemBuilder: (context, index) {
                              return InkWell(
                                  onTap: () {
                                    bottomState(() {
                                      setState(() {
                                        address = data[index]['address_name'].toString();
                                        x = data[index]['x'].toString();
                                        y = data[index]['y'].toString();
                                      });
                                    });
                                    Navigator.pop(context, data[index]['address_name'].toString());
                                  },
                                  child: Container(
                                      child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      const SizedBox(height: 8),
                                      Text(
                                        data[index]['place_name'].toString(),
                                        style: const TextStyle(color: Colors.white, fontFamily: 'NanumSquareNeo', fontSize: 20),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        data[index]['address_name'].toString(),
                                        style: const TextStyle(color: Colors.white54, fontFamily: 'NanumSquareNeo', fontSize: 15),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        data[index]['x'].toString(),
                                        style: const TextStyle(color: Colors.white54, fontFamily: 'NanumSquareNeo', fontSize: 15),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        data[index]['y'].toString(),
                                        style: const TextStyle(color: Colors.white54, fontFamily: 'NanumSquareNeo', fontSize: 15),
                                      ),
                                      const SizedBox(height: 8),
                                      const Divider(
                                        color: Colors.white54,
                                        thickness: 0,
                                        height: 0,
                                      ),
                                    ],
                                  )));
                            },
                            itemCount: data.length,
                            controller: _scrollController,
                          ),
                  ),
                ]))));
  }

  Future<String?> getJSONData(String value) async {

    var url = 'https://dapi.kakao.com/v2/local/search/keyword.json?target=place_name&query=$value';
    var response = await http.get(Uri.parse(url), headers: {"Authorization": "KakaoAK 37e042617856e851454e08c71556238d"});

    setState(() {
      data.clear();
      var dataConvertedToJSON = json.decode(response.body);
      List result = dataConvertedToJSON["documents"];
      data.addAll(result);
    });

    return response.body;
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
                      // TODO: 내 장소 수정하기 기능 추가
                      String oldLabel = location.location;
                      String oldAddress = location.address;
                      String oldX = location.x;
                      String oldY = location.y;
                      int? id = location.id;
                      _textController.text = oldLabel;
                      address = oldAddress;
                      x = oldX;
                      y = oldY;
                      showModalBottomSheet<void>(
                        isScrollControlled: true,
                        backgroundColor: CustomColors.sheetBackgroundColor,
                        context: context,
                        builder: (BuildContext context) {
                          return _modifyLocation(id!, oldLabel, oldAddress, oldX, oldY);
                        },
                      ).then((value) {
                        setState(() {});
                        _textController.clear();
                        address = '';
                        x = '';
                        y = '';
                      });
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

  StatefulBuilder _modifyLocation(int id, String oldLabel, String oldAddress, String oldX, String oldY) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter bottomState) => SizedBox(
              height: MediaQuery.of(context).size.height * 0.92,
              child: Align(
                alignment: const Alignment(0.0, -0.9),
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
                        '내 장소 수정',
                        style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 20),
                      ),
                      TextButton(
                        onPressed: () {
                          updateLocation(LocationInfo(id: id, location: _textController.text, address: address, x: x, y: y));
                          bottomState(() {
                            setState(() => loadLocations());
                          });
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
                      // height: 100,
                      height: 200,
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
                            ]),
                            _LocationItem1(children: <Widget>[
                              const Text(
                                '주소',
                                style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 15),
                              ),
                              // TODO: 우측에 생기는 Padding 없애기
                              CupertinoButton(
                                  onPressed: () {
                                    _addressTextController.clear();
                                    data.clear();
                                    address = '';
                                    // result = '';
                                    showModalBottomSheet<void>(
                                      isScrollControlled: true,
                                      backgroundColor: CustomColors.sheetBackgroundColor,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return _searchLocation();
                                      },
                                    ).then((value) {
                                      bottomState(() {
                                        setState(() {});
                                      });
                                    });
                                  }, // TODO
                                  child: Text(
                                    address,
                                    // TODO - 주소 변수
                                    style: const TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white54, fontSize: 15),
                                  )),
                            ]),
                            _LocationItem1(children: <Widget>[
                              const Text(
                                'x',
                                style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 15),
                              ),
                              // TODO: 우측에 생기는 Padding 없애기
                              SizedBox(
                                  width: 200,
                                  child: Text(
                                    x,
                                    // TODO - 주소 변수
                                    style: const TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white54, fontSize: 15),
                                  )),
                            ]),
                            _LocationItem1(children: <Widget>[
                              const Text(
                                'y',
                                style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white, fontSize: 15),
                              ),
                              // TODO: 우측에 생기는 Padding 없애기
                              SizedBox(
                                  width: 200,
                                  child: Text(
                                    y,
                                    // TODO - 주소 변수
                                    style: const TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.white54, fontSize: 15),
                                  )),
                            ]),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 50,
                      width: 340,
                      decoration: BoxDecoration(color: CustomColors.tableBackgroundColor, borderRadius: const BorderRadius.all(Radius.circular(12))),
                      child: TextButton(
                        onPressed: () {
                          deleteLocation(id);
                          setState(() => loadLocations());
                          Navigator.pop(context);
                        },
                        child: const Text(
                          '알림 삭제',
                          style: TextStyle(fontFamily: 'NanumSquareNeo', color: Colors.red, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ));
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
      // onChanged: (String value) {
      //   fieldValue('The text has changed to: $value');
      // },
      onSubmitted: (String value) {
        fieldValue('Submitted text: $value');
      },
    );
  }
}
