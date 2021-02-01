import 'package:flutter/material.dart';
import 'package:location_finder/models/place.dart';
import 'package:location_finder/screens/location_finder.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        body: LocationFinder(
          '',
          onConfirm: (place) {
            print(
                'User confirmed location as : ${(place as Place).lat},${(place as Place).lng}');
          },
        ),
      ),
    );
  }
}
