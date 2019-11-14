import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'secret.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

Future<Reponses> fetchPost(String location, String choose) async {
  final response =
  await http.get('https://api.foursquare.com/v2/venues/search?near='+location+'&query='+choose+'&client_id='+clientID+'&client_secret='+clientSecret+'&v=20191104');

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON.
    return Reponses.fromJson(json.decode(response.body));
    //print(json.decode(response.body));

  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}

class ItemReponse {
  String id;
  String name;
  String description;
  List<String> photos = new List();
  List<String> comments = new List();
  String commentsBis;
  String latitude;
  String longitude;
  //String address;
  String city;
  String region;
  String country;
  String cat;

  ItemReponse(String id, String name){
    this.id= id;
    this.name= name;
  }

  ItemReponse.toString(){
    print("id : "+this.id + ", name : "+this.name);
  }

  setDescription(String desc){
    this.description = desc;
  }
  setComments(List<String> comm){
    this.comments = comm;
  }
  setPhotos(List<String> ph){
    this.photos = ph;
  }
  setLatitude(String lat){
    this.latitude = lat;
  }
  setLongitude(String long){
    this.longitude = long;
  }

}

class Reponses {
  final List<ItemReponse> listeReponses;

  Reponses({this.listeReponses});

  factory Reponses.fromJson(Map<String, dynamic> json) {
    List<ItemReponse> tes = new List<ItemReponse>();
    for (var items in json["response"]["venues"]) {
      ItemReponse itemReponse = new ItemReponse(items["id"], items["name"]);
      tes.add(itemReponse);

    }
    return Reponses(listeReponses: tes);
  }
}

Future<ReponsesDetails> getVenueDetails(ItemReponse itemReponse) async {
  final response =
  await http.get('https://api.foursquare.com/v2/venues/'+itemReponse.id+'?client_id='+clientID+'&client_secret='+clientSecret+'&v=20191104');

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON.
    return ReponsesDetails.fromJson(json.decode(response.body));
    //print(json.decode(response.body));

  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}

class ReponsesDetails {
  ItemReponse itemReponse;

  ReponsesDetails({this.itemReponse});

  factory ReponsesDetails.fromJson(Map<String, dynamic> json) {
    ItemReponse itemR = new ItemReponse(json["response"]["venue"]["id"], json["response"]["venue"]["name"]);
    itemR.setLatitude(json["response"]["venue"]["location"]["lat"].toString());
    itemR.setLongitude(json["response"]["venue"]["location"]["lng"].toString());
    if(json["response"]["venue"]["description"] != null){
      itemR.setDescription(json["response"]["venue"]["description"]);
    }else{
      itemR.description = null;
    }
    if(json["response"]["venue"]["tips"]["groups"][0]["items"].toString().length > 2){
      itemR.commentsBis = (json["response"]["venue"]["tips"]["groups"][0]["items"][0]["text"]);
    } else {
      itemR.commentsBis = null;
    }
    if(json["response"]["venue"]["bestPhoto"] != null){
      itemR.photos.add(
          json["response"]["venue"]["bestPhoto"]["prefix"]+
              json["response"]["venue"]["bestPhoto"]["width"].toString()+
              "x"+
              json["response"]["venue"]["bestPhoto"]["height"].toString()+
              json["response"]["venue"]["bestPhoto"]["suffix"]

      );
    }else{
      itemR.photos.add(
        "https://www.prendsmaplace.fr/wp-content/themes/prendsmaplace/images/defaut_image.gif"
      );
    }
    if(json["response"]["venue"]["categories"].toString().length > 2) {
      itemR.cat = json["response"]["venue"]["categories"][0]["name"];
    }else{
      itemR.cat = null;
    }

    return ReponsesDetails(itemReponse: itemR);
  }
}

class _MyHomePageState extends State<MyHomePage> {

  final myControllerLocation = TextEditingController();
  final myControllerChoose = TextEditingController();
  List<ItemReponse> listeReponses = new List<ItemReponse>();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myControllerLocation.dispose();
    myControllerChoose.dispose();
    super.dispose();
  }

  Widget equalNull(BuildContext context, Object obj, String text) {
    if(Object != null){
      return Text(text+" : "+obj);
    }else{
      return Text(text+" : Non référencée !");
    }
  }

  @override
  Widget _MySecondPageStatsse(BuildContext context, ItemReponse item) {

    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: Center(

        child: Column(
          children: <Widget>[
            Text(
              item.name??'Aucun Titre',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            equalNull(context, item.cat, "Categorie"),

            Text(item.description??'Description : Non référencée !'),
            Image.network(
              item.photos[0]
            ),
            Text(
              'Commentaire :',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
                item.commentsBis??'Aucune Commentaires !'
            ),
            InkWell(
                child: new
                  Text(
                    'Show on the Map',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                onTap: () => {
                  launch('https://www.google.fr/maps/search/'+item.latitude+','+item.longitude)
                }
            ),
          ],

        ),

      ),

    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.start,

          children: <Widget>[
            TextField(
              controller: myControllerLocation,
              decoration: InputDecoration(
                  hintText: 'Lieu'
              ),
            ),
            TextField(
              controller: myControllerChoose,
              decoration: InputDecoration(
                  hintText: 'Rechercher'
              ),
            ),
            FlatButton.icon(
              color: Colors.grey,
              icon: Icon(Icons.search), //`Icon` to display
              label: Text('Lancer la recherche'), //`Text` to display
              onPressed: () {

                fetchPost(myControllerLocation.text, myControllerChoose.text).then((result) {
                    listeReponses.clear();
                    setState(() {
                      listeReponses.addAll(result.listeReponses);
                    });
                });
              },
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: listeReponses.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      child : Container(
                        height: 50,
                        margin: EdgeInsets.all(5.0),
                        color: Colors.amber[500],
                        child: Center(child: Text( listeReponses[index].name)),
                      ),
                      onTap: () => {
                        getVenueDetails(listeReponses[index]).then((result) {

                          Navigator.push(context, MaterialPageRoute(builder: (_) => _MySecondPageStatsse(context, result.itemReponse)));

                        }),

                      }
                    );
                  }
              ),
            ),

          ],
        ),

      ),

    );
  }
}