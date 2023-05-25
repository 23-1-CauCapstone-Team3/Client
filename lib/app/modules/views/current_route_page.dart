import 'package:flutter/material.dart';
import 'package:last_transport/app/modules/views/lock_screen_activity_page.dart';

import '../../data/theme_data.dart';

class CurrentRoutePage extends StatefulWidget {
  const CurrentRoutePage({Key? key}) : super(key: key);

  @override
  _CurrentRoutePageState createState() => _CurrentRoutePageState();
}

class _CurrentRoutePageState extends State<CurrentRoutePage> with AutomaticKeepAliveClientMixin {

  int _selectedIndex = 1;

  final List<Widget> pages = <Widget>[LockScreenActivityPage()];

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final pageController = PageController(initialPage: 1);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: CustomColors.pageBackgroundColor,
      body: PageView(
        controller: pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: pages,
      ),
    );

  }
}