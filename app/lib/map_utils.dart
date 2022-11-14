import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

double degreeToRadian(double degree) => degree * pi / 180;

double radianToDegree(double radian) => radian * 180 / pi;

class XYZ {
  late double x;
  late double y;
  late double z;
  XYZ({
    this.x = 0, 
    this.y = 0,
    this.z = 0
  });

  static LatLng toLatLng(XYZ point){
    double r = sqrt( pow(point.x, 2) + pow(point.y, 2) +  pow(point.z, 2));
    double latRadians = asin(point.z / r);
    double lngRadians = atan2(point.y, point.x);
    return LatLng(radianToDegree(latRadians), radianToDegree(lngRadians));
  }

  static XYZ fromLatLng(LatLng point){
    double R = 6378137.0;
    double latRadians = degreeToRadian(point.latitude);
    double lngRadians = degreeToRadian(point.longitude);
    return XYZ(
      x: R*cos(latRadians)*cos(lngRadians), 
      y: R*cos(latRadians)*sin(lngRadians), 
      z: R*sin(latRadians)
    );
  }
}



class LineSegment {
  late dynamic start;
  late dynamic end;
  late Type pointsType;

  LineSegment({
    this.start, 
    this.end
  }) {
    if(start.runtimeType != end.runtimeType) {
      throw "Point types must be equal";
    }
    pointsType = start.runtimeType;
  }

  double get length{
    if (pointsType == LatLng){
      return Geolocator.distanceBetween(start.latitude, start.longitude, end.latitude, end.longitude);
    } else if (pointsType == XYZ){
      return sqrt(pow(start.x - end.x, 2) + pow(start.y - end.y, 2) + pow(start.z - end.z, 2));
    } else {
      return -1;
    }
  }

  double distanceToPoint(dynamic point){
    // Convert start and end to XYZ
    XYZ _start = pointsType == LatLng ? XYZ.fromLatLng(start) : start;
    XYZ _end = pointsType == LatLng ? XYZ.fromLatLng(end) : end;
    // Convert point to XYZ
    XYZ _point = point.runtimeType == LatLng ? XYZ.fromLatLng(point) : point;
    // U
    double u = (
      (_point.x - _start.x) * (_end.x - _start.x) + 
      (_point.y - _start.y) * (_end.y - _start.y)
    ) / pow(length, 2);
    // Get coords for new point
    double x = _start.x + u * (_end.x - _start.x);
    double y = _start.y + u * (_end.y - _start.y);
    // Get distance
    return sqrt( pow(_point.x - x, 2) + pow(_point.y - y, 2) );
  }

}

class Path {
  List<dynamic> points = [];
  List<LineSegment> lineSegments = [];
  Path({ this.points = const [] }) {
    for (dynamic point in points) {
      addPoint(point);
    }
  }

  void addPoint(dynamic point){
    lineSegments = [];
    if(points.length < 2) return;
    for(int i = 1; i < points.length; i++){
      LineSegment line = LineSegment(start: points[i-1], end: points[i]);
      lineSegments.add(line);
    }
  }

  double distanceToPoint(dynamic point){
    double minDistance = double.infinity;
    for (LineSegment line in lineSegments){
      double distance = line.distanceToPoint(point);
      minDistance = min(distance, minDistance);
    }
    return minDistance;
  }

  double get length{
    double totalLength = 0;
    for (LineSegment line in lineSegments){
      totalLength += line.length;
    }
    return totalLength;
  }

}

class MapDirectionsStep {
  late Path path = Path();
  late double distanceValue;
  late double durationValue;
  late String htmlInstructions;
  late String maneuver;
  late String travelMode;

  MapDirectionsStep({
    List<List<double>> points = const [], 
    this.distanceValue = 0,
    this.durationValue = 0, 
    this.htmlInstructions = "", 
    this.maneuver = "", 
    this.travelMode = ""
  }) {
    for (List<double> point in points){
      path.addPoint( LatLng(point[0], point[1]) );
    }
  }

  MapDirectionsStep.fromJson(Map<String, dynamic> json)
  : path = Path(
    points: json["polyline"]["decoded_points"].map((p) => LatLng(p[0], p[1])).toList()
  ),
  distanceValue = json["distance"]["value"].toDouble(), 
  durationValue = json["duration"]["value"].toDouble(), 
  maneuver = json["maneuver"] ?? "", 
  htmlInstructions = json["html_instructions"] ?? "", 
  travelMode = json["travel_mode"];

  double missingDistance(){
    return distanceValue;
  }
  double missingDuration(){
    return durationValue;
  }
}

class MapDirections {
  late List<MapDirectionsStep> steps;
  int currentStepIndex = -1;

  MapDirections({
    this.steps = const [], 
  });

  void updatePosition(List<double> point, double tolerance, Function? onOutOfPath){
    int previousStepIndex = currentStepIndex;
    double closestDistance = double.infinity;
    // Get closest step
    for (int i = 0; i < steps.length; i++){
      double distance = steps[i].path.distanceToPoint( LatLng(point[0], point[1]) );
      if (distance < closestDistance){
        closestDistance = distance;
        currentStepIndex = i;
      }
    }
    print("$currentStepIndex\t$closestDistance");
    if(closestDistance > tolerance){
      onOutOfPath!();
    }
    //currentStepIndex = 1;
  }

  MapDirectionsStep? getCurrentStep(){
    if(currentStepIndex == -1) return null;
    return steps[currentStepIndex];
  }

  MapDirectionsStep? getNextStep(){
    if(currentStepIndex == -1) return null;
    if(currentStepIndex >= steps.length - 1) return null;
    return steps[currentStepIndex + 1];
  }

  Polyline getPolyLine(){
    List<LatLng> points = [
      LatLng(steps[0].path.points[0].latitude, steps[0].path.points[1].longitude)
    ];
    for (MapDirectionsStep step in steps){
      for (dynamic point in step.path.points){
        points.add( LatLng(point.latitude, point.longitude) );
      }
    }
    return Polyline(
      polylineId: const PolylineId("a"), 
      visible: true, 
      points: points, 
      width: 15, 
      color: Colors.blue
    );
  }
}