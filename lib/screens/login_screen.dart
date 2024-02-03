import 'package:flutter/material.dart';
import 'registration_screen.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_app/providers/auth_provider.dart' as CustomAuthProvider;

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Account', style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<CustomAuthProvider.AuthProvider>( // needed to ad 'Consumer' to rebuild screen after succesfull login and logout
        builder: (context, authProvider, child) {
          return authProvider.currentUser != null
              ? LoggedInContent(authProvider: authProvider)
              : LoginForm(authProvider: authProvider);
        },
      ),
    );
  }
}

class LoggedInContent extends StatelessWidget {
  final CustomAuthProvider.AuthProvider authProvider;

  const LoggedInContent({Key? key, required this.authProvider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Hello ${authProvider.name ?? ""} ${authProvider.surname ?? ""}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your statistics are updated between your devices.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add logout functionality
                authProvider.signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}



class LoginForm extends StatelessWidget {
  final CustomAuthProvider.AuthProvider authProvider;

  const LoginForm({Key? key, required this.authProvider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Login',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        LoginFormWidget(authProvider: authProvider),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegistrationScreen()),
            );
          },
          child: const Text(
            "Don't have an account? Register here",
            style: TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

class LoginFormWidget extends StatefulWidget {
  final CustomAuthProvider.AuthProvider authProvider;

  const LoginFormWidget({Key? key, required this.authProvider}) : super(key: key);

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          _buildTextField(_email, 'Email'),
          const SizedBox(height: 16),
          _buildTextField(_password, 'Password', isPassword: true),
          const SizedBox(height: 16),
          _buildLoginButton(),
          if (_isLoading) const CircularProgressIndicator(), // Show loading indicator
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _performLogin,
        style: ElevatedButton.styleFrom(
          primary: Colors.blueAccent,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Login', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _performLogin() async {
    setState(() {
      _isLoading = true;
    });

    final email = _email.text;
    final password = _password.text;

    try {
      await widget.authProvider.signInWithEmailAndPassword(email, password);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}


