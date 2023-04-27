import 'package:flutter/material.dart';

class CurrentRoutePage extends StatefulWidget {
  const CurrentRoutePage({Key? key}) : super(key: key);

  @override
  _CurrentRoutePageState createState() => _CurrentRoutePageState();
}

class _CurrentRoutePageState extends State<CurrentRoutePage> {

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('This is a Current Route Page'),
    );
  }
}