import 'package:app/contacts_screen.dart';
import 'package:app/map_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/flutter_html.dart';

class MapPane_DirectionsStep extends StatelessWidget {
  late MapDirectionsStep? step;

  MapPane_DirectionsStep({
    Key? key,
    this.step
  }) : super(key: key);

  @override
  Widget build(BuildContext context){
    double width = MediaQuery.of(context).size.width;
    return Container(
       width: width,
       padding: const EdgeInsets.all(8),
       child: ListTile(
        tileColor: Colors.green,
        title: Html(data: step!.htmlInstructions),
       ),
    );
  }
}

class MapPane extends StatelessWidget {
  late MapDirections? directions;
  late String? destination;
  late Function? onEmergencyScreen;
  late Function? onDestinationRemove;
  late int? currentStepIndex;

  late ScrollController _scrollController = ScrollController();

  MapPane({
    Key? key, 
    this.directions, 
    this.destination, 
    this.onEmergencyScreen,
    this.onDestinationRemove,
  }) : super(key: key);


  void scrollTo(double offset){
    _scrollController.animateTo(offset, duration: Duration(seconds: 2), curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context){
    return Material(
      color: Colors.black,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: PageScrollPhysics(),
              controller: _scrollController,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: directions!.steps.map((step) => MapPane_DirectionsStep(step: step)).toList(),
              ),
            ),
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
            )
          ],
        ),
      )
    );
  }
}