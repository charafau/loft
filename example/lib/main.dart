import 'package:example/database.dart';
import 'package:example/user.dart';
import 'package:example/user_dao.dart';
import 'package:flutter/material.dart';
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

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Loft example'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            RaisedButton(
              child: Text('create database'),
              onPressed: () {
                TodoDatabase().generate();
              },
            ),
            RaisedButton(
              child: Text('insert user'),
              onPressed: () {
                var uDao = UserDao();
                uDao.insert(User(name: "Bob", age: 25));
              },
            ),
          ],
        ),
      ),
    );
  }
}
