import 'package:flutter/material.dart';

class User {
  final String name;
  final String surname;

  User({required this.name, required this.surname});
}

class UserProvider extends ChangeNotifier {
  User? _user;

  User? get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void signOut() {
    _user = null;
    notifyListeners();
  }
}
