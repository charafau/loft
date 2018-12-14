// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// LoftGenerator
// **************************************************************************

class _$User extends User {
  String generate() {
    return 'CREATE TABLE User (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, name TEXT, age INTEGER) ;';
  }

  String drop() {
    return 'DROP TABLE IF EXISTS User;';
  }
}
