import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mic_stream/mic_stream.dart';
//import 'package:noise_meter/noise_meter.dart';

class UserSensors extends StatefulWidget {
  @override
  State<UserSensors> createState() => UserSensorsState(); 
}

class UserSensorsState extends State<UserSensors> {
  //late StreamSubscription<NoiseReading> noiseSubscription;

  String noiseMeanDecibels = "";
  @override
  void initState() {
    super.initState();
    /* noiseSubscription = NoiseMeter().noiseStream.listen((NoiseReading noiseReading) { 
      setState(() {
        noiseMeanDecibels = noiseReading.meanDecibel;
      });
    }); */
    startMicrophone();
  }

  void startMicrophone() async {
    MicStream.shouldRequestPermission(true);
    Stream<Uint8List>? stream = await MicStream.microphone(sampleRate: 44100);
    StreamSubscription<Uint8List> microhoneSubscription = stream!.listen((event) { 
      print("AAA");
      setState(() {
        noiseMeanDecibels = event.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context){
    return SafeArea(
      child: Container(
        child: Text(noiseMeanDecibels),
      ),
    );
  }
}