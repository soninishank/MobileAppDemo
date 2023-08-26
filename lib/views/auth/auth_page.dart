import 'package:flutter/material.dart';

import '../../util/error_handler.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Insightful'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                try {
                  Navigator.pushNamed(context, 'login');
                } catch (e) {
                  ErrorHandler.showErrorDialog(
                      context, 'Error navigating to login: $e');
                }
              },
              child: Text('Login'),
            ),
            ElevatedButton(
              onPressed: () {
                try {
                  Navigator.pushNamed(context, 'register');
                } catch (e) {
                  ErrorHandler.showErrorDialog(
                      context, 'Error navigating to Register: $e');
                }
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
