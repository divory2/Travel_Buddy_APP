import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import '.env.dart' as placesApiKey;
import '.env.dart';

class Planner extends StatefulWidget{
  const Planner({super.key,});
  @override
  _PlannerState  createState() => _PlannerState(); 

}

class _PlannerState extends State<Planner>{

final _controller =  TextEditingController();
var uuid =  const Uuid();
String _sessionToken = '1234567890';
List<dynamic> _placeList = [];
List<String> destinationList=[];


@override
void initState() {
  super.initState();
  _controller.addListener(() {
    _onChanged();
  });
}



  void _onChanged() {
  if (_sessionToken == null) {
    setState(() {
      _sessionToken = uuid.v4();
    });
  }
  getSuggestion(_controller.text);
}
void _addToDestinationList(String des){
  destinationList.add(des);
  print("****destination List***** $destinationList");
}



void getSuggestion(String input) async {


  String placesApiKey= PLACES_API_KEY;

  try{
    String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request = '$baseURL?input=$input&key=$placesApiKey&sessiontoken=$_sessionToken';
    var response = await http.get(Uri.parse(request));
    var data = json.decode(response.body);
    if (kDebugMode) {
      print('mydata');
      print(data);
    }
    if (response.statusCode == 200) {
      setState(() {
        print('********* Response body:********${response.body}');
        _placeList = json.decode(response.body)['predictions'];
      });
    } else {
      throw Exception('Failed to load predictions');
    }
  }catch(e){
    print(e);
  }

}
Future<void> _viewDestinations(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Your Destinations'),
      content: SizedBox(
        width: double.maxFinite,
        child: destinationList.isEmpty
            ? Text('No destinations added yet.')
            : SingleChildScrollView(
                child: ListBody(
                  children: destinationList
                      .map((destination) => ListTile(title: Text(destination)))
                      .toList(),
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        )
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Planner"),
      
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Please type A Location you would like to go',
                suffix: IconButton(onPressed: (){
                  _controller.clear();
                }, icon: const Icon(Icons.cancel))
              ),
              onChanged: (value) => _onChanged(),
              
            ),
            Expanded(
              child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _placeList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  
                  onTap: () async {
                    _addToDestinationList(_placeList[index]["description"]);
                  },
                  child: ListTile(
                    title: Text(_placeList[index]["description"]),
                  ),
                );
              },
            ),),
            ElevatedButton(onPressed: (){
                _viewDestinations(context);
            }, child: Text('View Destination List'))
          ],
        ),
      ),

    );
  }
}