import 'package:app/contacts_screen.dart';
import 'package:app/emergency_screen.dart';
import 'package:app/map_screen.dart';
import 'package:app/search_screen.dart';
import 'package:app/user_sensors.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: /* MapScreen(
        startLocation: "One Infinite Loop",
        endLocation: "One Apple Park Way",
      ) */ App()
    );
  }
}

class App extends StatefulWidget {
  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  bool hasLocationPermission = false;
  String? origin;
  String? destination;

  @override
  void initState() {
    super.initState();
    getLocationPermission().then((value){
      //getCurrentLocation();
    });
    destination = null;
  }

  Future getLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    setState(() {
      hasLocationPermission = !(permission == LocationPermission.denied || permission == LocationPermission.deniedForever);
    });
  }

  @override
  Widget build(BuildContext context){
    print("Origin is: $origin");
    if (!hasLocationPermission){
      return Container(
        child: const Text("Please provide permission"),
      );
    }
    if (destination == null){
      return SearchScreen(
        onDestinationChange: (String d){
          EmergencyScreen.isShowing = true;
          setState(() {
            destination = d;
          });
        },
      );
    }
    return MapScreen(
      destination: destination ?? "",
      onDestinationRemove: () async {
        //await getCurrentLocation();
        setState(() {
          destination = null;
        });
      },
      onEmergency: (){
        
      },
    );
  }
}