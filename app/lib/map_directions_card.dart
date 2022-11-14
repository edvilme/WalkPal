import 'package:app/map_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';


class MapDirectionsCard extends StatelessWidget {
  final MapDirectionsStep? step;
  const MapDirectionsCard({
    Key? key, 
    this.step
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: Row(
        children: [
          // Icon
          Container(
            height: 40,
            width: 40,
            color: Colors.black,
            margin: const EdgeInsets.fromLTRB(16, 16, 8, 16),
          ),
          // Directions
          Flexible(
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  // Distance and duration
                  Text(
                    "${step?.missingDistance() ?? "0"} • ${step?.missingDuration() ?? "0"}",
                    style: const TextStyle(
                      fontSize: 14, 
                      fontWeight: FontWeight.w400,
                      color: Colors.white, 
                      decoration: TextDecoration.none
                    ),
                  ),
                  // HTML Instructions
                  Html(
                    data: step?.htmlInstructions ?? "Continue",
                    style: {
                      "body": Style(
                        padding: const EdgeInsets.all(0),
                        margin: const EdgeInsets.all(0), 
                        fontSize: const FontSize(19),
                        color: Colors.white, 
                        fontWeight: FontWeight.w600
                      )
                    },
                  )
                ],
              )
            ),
          )
        ],
      ),
    );
  }
}