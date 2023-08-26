import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 30),
          child: LoginForm(),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorText = '';
  bool _isEmailValid = true;

  void _validateEmail(String value) {
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    setState(() {
      _isEmailValid = emailRegex.hasMatch(value);
    });
  }

  Future<void> _login() async {
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Navigate to home screen on successful login
      Navigator.pushNamed(context, 'home');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _setErrorText('No user found with this email. Please register.');
      } else if (e.code == 'wrong-password') {
        _setErrorText('Wrong password provided for this user.');
      } else {
        _setErrorText('An error occurred. Please try again later.');
      }
    } catch (e) {
      _setErrorText('An error occurred. Please try again later.');
    }
  }

  void _setErrorText(String errorText) {
    setState(() {
      _errorText = errorText;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: 'Email',
            errorText: _isEmailValid ? null : 'Enter a valid email',
          ),
          onChanged: _validateEmail,
        ),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(hintText: 'Password'),
        ),
        if (_errorText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _errorText,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ElevatedButton(
          onPressed: _login,
          child: Text('Submit'),
        ),
      ],
    );
  }
}