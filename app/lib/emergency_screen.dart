import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';

enum EmergencyTypes {
  BUTTON_PRESSED,
  LOUD_NOISE, 
  HEAVY_MOVEMENT, 
  OFF_TRACK, 
  UNDEFINED
}

// ignore: must_be_immutable
class EmergencyScreen extends StatefulWidget {
  late Function? onDismiss;
  late Function? onConfirm;

  static bool isShowing = false;

  EmergencyTypes emergencyType;

  EmergencyScreen({
    Key? key, 
    this.onDismiss, 
    this.onConfirm, 
    this.emergencyType = EmergencyTypes.UNDEFINED
  }) : super(key: key);

  Future<String> fetchContacts() async {
    LocalStorage storage = LocalStorage("walkpal-emergency-contacts");
    Set<PhoneContact> results = {};
    var data = await storage.getItem("contacts");
    if (data == null) return "";
    for (var contact in data){
      results.add(PhoneContact.fromMap(contact));
    }
    return results.map((e) => 
      e.phoneNumber?.number
    ).join(";");
  }

  void sendMessage () async {
    Position? lastPosition = await Geolocator.getLastKnownPosition();
    String phoneNumbers = await fetchContacts();
    if(phoneNumbers == "") return;
    String currentDateTime = DateTime.now().toIso8601String();
    String body = "";
    switch(emergencyType){
      case EmergencyTypes.HEAVY_MOVEMENT:
        body = "[WalkPal] Hi, this emergency message was automatically sent because my phone detected very heavy movement (eg, sudden running) during my commute at time $currentDateTime.\nMy current location is: https://www.google.com/maps/@${lastPosition?.latitude},${lastPosition?.longitude},20z \nYou're receiving this message because you are one of my emergency contacts.";
        break;
      case EmergencyTypes.LOUD_NOISE:
        body = "[WalkPal] Hi, this emergency message was automatically sent because my phone detected very high levels of noise (eg, screaming, car sounds) during my commute at time $currentDateTime.\nMy current location is: https://www.google.com/maps/@${lastPosition?.latitude},${lastPosition?.longitude},20z \nYou're receiving this message because you are one of my emergency contacts.";
        break;
      case EmergencyTypes.OFF_TRACK:
        body = "[WalkPal] Hi, this emergency message was automatically sent because I deviated from my rute during my commute at time $currentDateTime.\nMy current location is: https://www.google.com/maps/@${lastPosition?.latitude},${lastPosition?.longitude},20z \nYou're receiving this message because you are one of my emergency contacts.";
        break;
      case EmergencyTypes.BUTTON_PRESSED:
      default:
        body = "[WalkPal] Hi, I pressed the danger button during my commute at time $currentDateTime.\nMy current location is: https://www.google.com/maps/@${lastPosition?.latitude},${lastPosition?.longitude},20z \nYou're receiving this message because you are one of my emergency contacts.";
        break;
    }

    http.Response response = await http.post(
      Uri.parse("https://walkpal-backend-fz2wu3nrwa-vp.a.run.app/message").replace(queryParameters: {
        "recipients": phoneNumbers, 
        "body": body
      })
    );
    //print(phoneNumbers);
    print(response.request!.url);
    //var data = jsonDecode(response.body);
  }

  @override
  State<EmergencyScreen> createState() => EmergencyScreenState();
}

class EmergencyScreenState extends State<EmergencyScreen> {
  late Timer _timer; 
  int timerValue = 10;

  @override
  void initState() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer t){
        setState(() {
          timerValue--;
          if(timerValue == 0){
            t.cancel();
            widget.sendMessage();
            widget.onConfirm!();
            // Navigator.pop(context);
          }
        });
      }
    );
    super.initState();
    EmergencyScreen.isShowing = true;
  }

  @override
  void dispose(){
    _timer.cancel();
    super.dispose();
    EmergencyScreen.isShowing = false;
  }

  @override
  Widget build(BuildContext context){
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
            ),
            // Title
            Text("Are you OK?", 
              style: TextStyle(
                decoration: TextDecoration.none, 
                fontSize: 40, 
                color: Colors.red.shade400,
              ),
              textAlign: TextAlign.center,
            ),
            // Description
            Container(
              padding: const EdgeInsets.all(16),
              child: 
                const Text("A text message with your current location will be sent to your emergency contacts and to the authorities. You will be redirected to the nearest safe place.", 
                style: TextStyle(
                  decoration: TextDecoration.none, 
                  fontSize: 16, 
                  color: Colors.white70, 
                  fontWeight: FontWeight.w400
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Center(
                child: Text(timerValue.toString(), 
                  style: const TextStyle(
                    decoration: TextDecoration.none, 
                    color: Colors.red, 
                    fontSize: 70, 
                    fontWeight: FontWeight.w300
                  ),
                ),
              )
            ), 
            ElevatedButton(
              onPressed: (){
                Navigator.pop(context);
                widget.onDismiss!();
              }, 
              child: const Text("Cancel, I'm OK"), 
            )
          ],
        ),
      ),
    );
  }
}