import 'package:flutter/material.dart';
import 'package:last_transport/app/data/theme_data.dart';
import 'current_route_page.dart';
import 'alarm_page.dart';
import 'my_location_page.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 1;

  final List<Widget> pages = <Widget>[CurrentRoutePage(), AlarmPage(), MyLocationPage()];

  void _onItemTapped(int index) {
    pageController.jumpToPage(index);
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final pageController = PageController();

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
      backgroundColor: CustomColors.pageBackgroundColor,
      body: PageView(
        controller: pageController,
        onPageChanged: _onPageChanged,
        children: pages,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: CustomColors.menuBackgroundColor,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.route),
            label: '현재 경로',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: '막차 알림',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '내 장소',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.white54,
        onTap: _onItemTapped,
      ),
    );
  }
}
