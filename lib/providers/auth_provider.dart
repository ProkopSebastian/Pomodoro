import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  String? name;
  String? surname;

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _fetchUserData();
      notifyListeners(); // Notify listeners after the user is logged in
    } catch (e) {
      throw e;
    }
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    try {
      String userId = _auth.currentUser?.uid ?? '';
      DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(userId).get();

      if (userSnapshot.exists) {
        name = userSnapshot.get('name');
        surname = userSnapshot.get('surname');
        //print('Name: $name');
        notifyListeners();
      }
      else {
        //print('no snapshot');
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    name = null;
    surname = null;
    notifyListeners(); // Notify listeners after the user is logged out
  }
}
