import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:last_transport/app/modules/views/lock_screen_activity_page.dart';
import 'package:last_transport/app/modules/views/subway_page.dart';
import 'package:last_transport/app/modules/views/walk_page.dart';

import '../../data/theme_data.dart';
import 'bus_page.dart';

class CurrentRoutePage extends StatefulWidget {
  const CurrentRoutePage({Key? key}) : super(key: key);

  @override
  _CurrentRoutePageState createState() => _CurrentRoutePageState();
}

class _CurrentRoutePageState extends State<CurrentRoutePage> with AutomaticKeepAliveClientMixin {

  var exBox = Hive.box('box_name');

  int _selectedIndex = 1;

  // final List<Widget> pages = <Widget>[LockScreenActivityPage()];

  late Widget page;

  // void _onPageChanged(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  // }

  // final pageController = PageController(initialPage: 1);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    if (exBox.get("isGuiding", defaultValue: false)){
      int nextRouteType = exBox.get("nextRouteType", defaultValue: 0);
      if(nextRouteType == 1){
        page = SubwayPage();
        // print(nextRouteType);
      }
      else if (nextRouteType == 2){
        // print(nextRouteType);
        page = BusPage();
      } else if (nextRouteType == 3) {
        // print(nextRouteType);
        page = WalkPage();
      } else if (nextRouteType == 4) {
        // print(nextRouteType);
        page = WalkPage();
      } else if (nextRouteType == 5) {
        // page = TexiPage();
        // print(nextRouteType);
        page = LockScreenActivityPage();
      } else {
        // print(nextRouteType);
        page = LockScreenActivityPage();
      }
    }
    else {
      // print('else');
      page = LockScreenActivityPage();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: CustomColors.pageBackgroundColor,
      // body: PageView(
      //   controller: pageController,
      //   onPageChanged: _onPageChanged,
      //   physics: const NeverScrollableScrollPhysics(),
      //   children: pages,
      // ),
      body: page,
    );

  }
}