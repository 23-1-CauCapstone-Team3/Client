import 'package:flutter/material.dart';

class MyLocationPage extends StatefulWidget {
  const MyLocationPage({Key? key}) : super(key: key);

  @override
  _MyLocationPageState createState() => _MyLocationPageState();
}

class _MyLocationPageState extends State<MyLocationPage> {

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('This is a My Location Page'),
    );
  }
}