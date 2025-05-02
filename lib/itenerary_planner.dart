import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
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
List<dynamic> _directionPlaceList = [];
List<dynamic> legs = [];
List<dynamic> steps =[];
List <String> insturctionsList = [];
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
       // _placeListId = json.decode(response.body)['place_id'];

        print("PlaceList##################: $_placeList");
       //'
       //[['['
       //']]] print("**************************PlaceListID##################: $_placeListId");

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
                  children: destinationList.map((destination){
                        return ListTile(
                          title: Text(destination),
                          trailing: IconButton(
                                  onPressed: () => _getDirectionsTo(destination, context), 
                                  icon: Icon(Icons.directions)
                          ),
                          
                          
                        );
                      }).toList(),
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

void _ShowDirections(BuildContext context){
    showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Your Directions'),
      content: SizedBox(
        width: double.maxFinite,
        child: insturctionsList.isEmpty
            ? Text('No Directions added yet.')
            : SingleChildScrollView(
                child: ListBody(
                  children: insturctionsList.map((insturction){
                    return ListTile(
                      title: Text(insturction),
                    );
                  }).toList(),
                )
                 
                ),
              ),
              actions: [
        TextButton(
          onPressed: () { 
            Navigator.pop(context);
            setState(() {
              insturctionsList.clear();
            });
            } ,
          child: Text('Close'),
        )
      ],

    )
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
                    leading: IconButton(
                      onPressed: (){
                        _getDirectionsTo(_placeList[index]["place_id"],context);
                      }, 
                      icon: Icon(Icons.directions)
                      ),
                    title: Text(_placeList[index]["description"]),
                  ),
                );
              },
            ),),
            ElevatedButton(onPressed: (){
                _viewDestinations(context);
            }, child: Text('View Destination List')),
            
          ],
        ),
      ),

    );
  }

 



Future<Position> _getCurrentLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Location services are disabled.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception('Location permissions are permanently denied');
  }

  return await Geolocator.getCurrentPosition();
}





Future<void> _getDirectionsTo(String destinationid, BuildContext context) async {
    String placesApiKey= PLACES_API_KEY;

  try{

    print("Destination Id ************* $destinationid");
    final origindestination = await _getCurrentLocation();
    final origin = '${origindestination.latitude},${origindestination.longitude}';
    print("######Your Destination latitude and longitude${origin}***********************");
    String baseURL = 'https://maps.googleapis.com/maps/api/directions/json';
    String request = '$baseURL?destination=place_id:$destinationid&origin=$origin&key=$placesApiKey';
    var response = await http.get(Uri.parse(request));
    var data = json.decode(response.body);
    if (kDebugMode) {
      print('mydata');
      print(data);
    }
    if (response.statusCode == 200) {
      setState(() {
        print('********* Response body:********${response.body}');
        _directionPlaceList = json.decode(response.body)['routes'];
        if(_directionPlaceList.isNotEmpty){
           legs = _directionPlaceList[0]['legs'] as List<dynamic>;
        }
        if(legs.isNotEmpty){
          steps = legs[0]['steps'] as List<dynamic>;
          for(final step in steps){
              final htmInstuction =step['html_instructions'];
              final tagsRemvoed = removeHTMLTags(htmInstuction);
            insturctionsList.add(tagsRemvoed);
          }
        }
      
       // _placeListId = json.decode(response.body)['place_id'];
        print("PlaceList##################: $_directionPlaceList");
        print("**************************PlaceListID##################: $_directionPlaceList");
          _ShowDirections(context);
      });

    } else {
      throw Exception('Failed to load predictions');
    }
  }catch(e){
    print(e);
  }




}
String removeHTMLTags(String instuctions){
  final RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
  return instuctions.replaceAll(exp, '');
}






}