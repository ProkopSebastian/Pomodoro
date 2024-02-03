import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_app/providers/auth_provider.dart' as CustomAuthProvider;

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Consumer<CustomAuthProvider.AuthProvider>(
        builder: (context, authProvider, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RegistrationForm(authProvider: authProvider),
            ],
          );
        },
      ),
    );
  }
}

class RegistrationForm extends StatefulWidget {
  final CustomAuthProvider.AuthProvider authProvider;

  const RegistrationForm({Key? key, required this.authProvider}) : super(key: key);

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _name = TextEditingController();
  final _surname = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(_name, 'Name'),
          _buildTextField(_surname, 'Surname'),
          _buildTextField(_email, 'Email'),
          _buildTextField(_password, 'Password'),
          const SizedBox(height: 24),
          _buildRegisterButton(),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        onPressed: _isLoading
            ? null //tu sie zrobil balagan, trzeba samemu wrocic na inny akran po zalogowaniu
            : () async {
          //print("próbuje zarejestrowawć2");
          final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: _email.text,
              password: _password.text,
          );
          //print("próbuje zarejestrowawć");
          // Get the user ID from the UserCredential
          final String userId = userCredential.user?.uid ?? '';

          // Create user data in Firestore
          await FirebaseFirestore.instance.collection('users').doc(userId).set({
            'name': _name.text,
            'surname': _surname.text,
            'email': _email.text,
          });

          // After successful registration, log in the user
          await widget.authProvider.signInWithEmailAndPassword(_email.text, _password.text);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
            ? const CircularProgressIndicator()
            : const Text('Register', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

