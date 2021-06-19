import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

Future<List<Photo>> fetchData() async {
  final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/photos'));
  return compute(parsePhotos, response.body);
}

List<Photo> parsePhotos(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Photo>((json) => Photo.fromJson(json)).toList();
}

class Photo {
  final int albumId;
  final int id;
  final String title;
  final String url;
  final String thumbnailUrl;
  Photo({
    this.albumId,
    this.id,
    this.title,
    this.url,
    this.thumbnailUrl,
  });
  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      albumId: json['albumId'] as int,
      id: json['id'] as int,
      title: json['title'] as String,
      url: json['url'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
    );
  }
}


void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future <List<Photo>> futurePhotos;

  @override
  void initState() {
    super.initState();
    futurePhotos = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter API and GridView Example',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter GridView'),
        ),
        body: Center(
          child: FutureBuilder <List<Photo>>(
            future: futurePhotos,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Photo> photos = snapshot.data;
                return 
                GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(),
                              settings: RouteSettings(
                                arguments: photos[index],
                              ),
                            ),
                          );
                        }, // handle your image tap here
                      child: Image.network(photos[index].thumbnailUrl),
                    );
                    // return Text(photos[index].thumbnailUrl);
                  },
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              // By default show a loading spinner.
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final photo = ModalRoute.of(context).settings.arguments as Photo;
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes da imagem'),
      ),
      body: Container(
          alignment: Alignment.center,
          child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                  child: Image.network(
                    photo.url,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return  child;

                      return CircularProgressIndicator();
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        Text('Some errors occurred!'),
                  ))
                 ],
              ),
            ),);
  }
}



/* class DetailScreen extends StatelessWidget {
  Future<Image> futurePh;
  @override
  Widget build(BuildContext context) {
    final photo = ModalRoute.of(context).settings.arguments as Photo;
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes da imagem'),
      ),
      body: Container(
        child: FutureBuilder <List<Photo>>(
            future: fetchPhotoUrl(photo.url),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Image ph = snapshot.data;
                return ph;
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              // By default show a loading spinner.
              return CircularProgressIndicator();
            },
          ),
      ));
  }
} 

Container(
        width: double.infinity,
        height: 280,
        alignment: Alignment.center,
        child: Image.network(
          photo.url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return  Center(child: child);

            return Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) =>
               Center(child: Text('Some errors occurred!')),
        ),
)


*/

