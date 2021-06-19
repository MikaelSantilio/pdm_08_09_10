import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future <List<User>> fetchData() async {
  final response =
      await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => new User.fromJson(data)).toList();
  } else {
    throw Exception('Unexpected error occured!');
  }
}

class User {
  final int id;
  final String name;
  final String username;
  final String email;

  User({this.id, this.name, this.username, this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
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
  Future <List<User>> futureUsers;

  @override
  void initState() {
    super.initState();
    futureUsers = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter API and ListView Example',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter ListView'),
        ),
        body: Center(
          child: FutureBuilder <List<User>>(
            future: futureUsers,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<User> data = snapshot.data;
                return 
                ListView.builder(
                itemCount: data.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                  title: Text(data[index].username),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(),
                        settings: RouteSettings(
                          arguments: data[index],
                        ),
                      ),
                    );
                  },
                );
                }
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
    final user = ModalRoute.of(context).settings.arguments as User;
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do usuário'),
      ),
      body: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Text(
                    user.name,
                    style: TextStyle(
                        fontSize: 22,
                    )
                  )),
                  Text(
                    "Username: ${user.username}",
                    style: TextStyle(
                        fontSize: 20,
                    )),
                  Text(user.email,
                    style: TextStyle(
                        fontSize: 20,
                    )),
                ],
              ),
            ],
          )),
    );
  }
}
