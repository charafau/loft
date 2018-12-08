import 'package:example/database.dart';
import 'package:example/user.dart';
import 'package:example/user_dao.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() {
    return new HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> {
  List<User> users = [];

  final nameController = TextEditingController();
  final ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    TodoDatabase().generate();
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Loft example'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RaisedButton(
                  child: Text('create database'),
                  onPressed: () async {
                    print('should generate');
                    await TodoDatabase().generate();
                  },
                ),
                RaisedButton(
                  child: Text('insert user'),
                  onPressed: () {
                    var uDao = UserDao();
                    uDao.insert(User(name: nameController.text.toString(), age:  int.parse(ageController.text)));
                    print('should insert');
                  },
                ),
                RaisedButton(
                  child: Text('fetch '),
                  onPressed: () async {
                    print('should fetch');
                    var uDao = UserDao();
                    List<User> all = await uDao.fetchAll();
                    print('fetched all: ${all.length}');
                    setState(() {
                      users = all;
                    });
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: 'User name'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextField(
                keyboardType: TextInputType.numberWithOptions(),
                controller: ageController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: 'User age'),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return ListItem(users[index]);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ListItem extends StatelessWidget {
  User _user;

  ListItem(this._user);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text("${_user.id}"),
      title: Text("${_user.name}"),
      subtitle: Text("${_user.age}"),
    );
  }
}
