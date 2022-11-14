import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;


class SearchScreen extends StatefulWidget {
  Function? onDestinationChange;
  SearchScreen({
    Key? key, 
    this.onDestinationChange
  }) : super(key: key);
  
  @override
  State<SearchScreen> createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  List<dynamic> results = [];

  Future<void> getResults(query) async {
    Position pos = await Geolocator.getCurrentPosition();
    http.Response response = await http.get(
      Uri.parse("https://walkpal-backend-fz2wu3nrwa-vp.a.run.app/search").replace(queryParameters: {
        'query': query,
        'latitude': pos.latitude.toString(), 
        'longitude': pos.longitude.toString()
      })
    );
    setState(() {
      results = jsonDecode(response.body);
    });
  }

  List<Widget> buildSearchResults(BuildContext context){
    return results.map((r) => r == null ? Container() :
      Material(
        child: ListTile(
          tileColor: Colors.black,
          textColor: Colors.white,
          title: Text(r?["name"],
            style: const TextStyle(fontWeight: FontWeight.w700),
          ), 
          subtitle: Text(r?["formatted_address"]),
          leading: Image.network(r?["icon"], 
            height: 24,
            width: 24,
          ),
          onTap: (){
            widget.onDestinationChange!(r?["formatted_address"]);
          },
        ),
      )
    ).toList();
  }

  @override 
  Widget build(BuildContext context){
    return Material(
      color: Colors.black,
      child: SafeArea(
        child: ListView(
          children: [
            const Text("Where to?", 
              style: TextStyle(
                decoration: TextDecoration.none, 
                fontSize: 40,
                color: Colors.white, 
                fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.center,
            ),
            TextField(
              textInputAction: TextInputAction.search,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: "Search",
                hintStyle: TextStyle(color: Colors.white60)
              ),
              style: const TextStyle(
                color: Colors.white
              ),
              onChanged: (String value) async {
                await getResults(value);
              },
            ),
            ...buildSearchResults(context)
          ],
        )
      ),
    );
  }
}