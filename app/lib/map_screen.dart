import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:app/contacts_screen.dart';
import 'package:app/emergency_screen.dart';
import 'package:app/map_directions_card.dart';
import 'package:app/map_pane.dart';
import 'package:app/map_utils.dart';
import 'package:app/walk_event_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MapNavigationPane extends StatelessWidget {
  late MapDirections? directions;
  late Function? onEmergencyScreen;
  late Function? onDestinationRemove;
  late String? destination;
  MapNavigationPane({
    Key? key, 
    this.directions,
    this.onEmergencyScreen,
    this.onDestinationRemove, 
    this.destination
  }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Material(
      color: Colors.black,
      child: Column(
        children: [
          /* ListView(
            scrollDirection: Axis.horizontal,
            children: directions!.steps.map((step) => (
              MapPane_DirectionsStep(step: step)
            )).toList(),
          ), */
          Row(
            children: [
              // Contacts screen button
              IconButton(
                icon: const Icon(Icons.account_circle_rounded),
                color: Colors.white,
                iconSize: 30,
                onPressed: (){
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => ContactsScreen())
                  );
                },
              ),
              // Destination
              Expanded(
                child: Container(
                  color: Colors.grey.shade800,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  child: InkWell(
                    child: Row(
                      children: [
                        // Icon
                        const Icon(Icons.cancel,
                          color: Colors.white,
                        ),
                        Flexible(
                          child: Text(destination ?? "",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        )
                      ],
                    ),
                    onTap: (){
                      onDestinationRemove!();
                    },
                  ),
                ),
              ),
              // Danger button
              Container(
                margin: const EdgeInsets.all(8),
                child: FloatingActionButton(
                  child: const Icon(Icons.warning_rounded),
                  backgroundColor: Colors.red,
                  onPressed: (){
                    onEmergencyScreen!();
                  }
                ),
              )
            ],
          ),
        ],
      )
    );
  }
}

class MapScreen extends StatefulWidget {
  late String? destination;
  late Function? onOutOfPath;
  late Function? onEmergency;
  late Function? onDestinationRemove;
  MapScreen({
    Key? key, 
    this.destination, 
    this.onOutOfPath,
    this.onDestinationRemove,
    this.onEmergency
  }) : super(key: key);
  @override State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  // Listen to changes
  late WalkEventListener listener;
  // Directions
  late MapDirections directions;
  // Dangerous areas and path
  late Set<Circle> dangerousAreas = {};
  late Set<Polyline> path = {};
  // Map controller
  Completer<GoogleMapController> googleMapsControllerCompleter = Completer();

  @override
  void initState() {
    super.initState();
    // Setup directions and listener
    listener = WalkEventListener(
      onPositionChange: (p0) {
        updatePosition(p0);
      },
      onAccelerationChange: (p0) {
        double magnitude = sqrt(pow(p0.x, 2) + pow(p0.y, 2) + pow(p0.z, 2));
        if (magnitude > 6){
          showEmergencyScreen(context, EmergencyTypes.HEAVY_MOVEMENT);
        }
      },
    );
    directions = MapDirections();
    // Get data
    getData();
  }

  @override
  void dispose() {
    listener.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Column(
      children: [
        Expanded(
          child: GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(0, 0),
              zoom: 18
            ),
            myLocationEnabled: true,
            circles: dangerousAreas,
            polylines: path,
            onMapCreated: (controller) {
              googleMapsControllerCompleter.complete(controller);
            },
          ),
        ),
        SafeArea(
          top: false,
          child: MapPane(
            directions: directions,
            destination: widget.destination,
            onEmergencyScreen: (){
              showEmergencyScreen(context, EmergencyTypes.BUTTON_PRESSED);
            },
            onDestinationRemove: (){
              widget.onDestinationRemove!();
            },
          ) 
        )
      ],
    );
  }

  Future getData() async {
    // Dangerous areas
    {
      http.Response response = await http.get(
        Uri.parse("https://walkpal-backend-fz2wu3nrwa-vp.a.run.app/dangerous-areas")
      );
      var data = jsonDecode(response.body);
      data.keys.forEach((key){
        var item = data[key];
        dangerousAreas.add(Circle(
          circleId: CircleId(item["Unnamed: 0"].toString()), 
          radius: item["radius"] / 3, 
          center: LatLng(item["centroid_lat"], item["centroid_lng"]), 
          strokeWidth: 8, 
          strokeColor: Colors.red, 
          fillColor: Colors.red.withOpacity(0.8)
        ));
      });
      setState(() {
        dangerousAreas = dangerousAreas;
      });
    }
    // Path
    {
      directions.steps = [];
      if(widget.destination == null) return;
      Position? lastPosition = await Geolocator.getLastKnownPosition();
      http.Response response = await http.get(
        Uri.parse("https://walkpal-backend-fz2wu3nrwa-vp.a.run.app/directions").replace(queryParameters: {
          "source": "${lastPosition?.latitude},${lastPosition?.longitude}", 
          "destination": widget.destination
        })
      );
      var data = jsonDecode(response.body);
      for (var step in data["legs"][0]["steps"]){
        directions.steps.add( MapDirectionsStep.fromJson(step) );
      }
      setState(() {
        path = {directions.getPolyLine()};
      });
    }
    // 
    EmergencyScreen.isShowing = false;
  }

  Future updatePosition(Position position) async {
    // Get map controller
    GoogleMapController controller = await googleMapsControllerCompleter.future;
    // Update map position
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          bearing: position.heading, 
          zoom: 18
        )
      )
    );
    // Update directions
    directions.updatePosition([position.latitude, position.longitude], position.accuracy*5, (){
      showEmergencyScreen(context, EmergencyTypes.OFF_TRACK);
    });
  }

  void showEmergencyScreen(BuildContext context, EmergencyTypes emergencyType){
    if(EmergencyScreen.isShowing) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmergencyScreen(
          emergencyType: emergencyType,
          onConfirm: (){
            widget.onEmergency!();
          },
          onDismiss: (){},
        ), 
        fullscreenDialog: true
      )
    );
  }
}