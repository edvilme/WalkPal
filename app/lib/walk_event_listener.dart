import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';

class WalkEventListener {
  late Function(Position)? onPositionChange;
  late Function(UserAccelerometerEvent)? onAccelerationChange;
  late Function? onNoiseLevelChange;

  // Subscriptions
  late StreamSubscription<Position> positionStream;
  late StreamSubscription<UserAccelerometerEvent> accelerationStream;

  WalkEventListener({
    this.onPositionChange,
    this.onAccelerationChange, 
    this.onNoiseLevelChange 
  }) {
    
    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high
      )
    ).listen((Position position) {
      onPositionChange!(position);
    });

    accelerationStream = userAccelerometerEvents.listen((UserAccelerometerEvent acceleration) {
      onAccelerationChange!(acceleration);
    });

  }

  void stop(){

    positionStream.cancel();
  }
}