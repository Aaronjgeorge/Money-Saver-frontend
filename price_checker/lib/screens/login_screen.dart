import 'package:flutter/material.dart';
import 'package:price_checker/screens/tab_screen.dart';
import 'package:price_checker/widgets/gradient_button.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:price_checker/providers/login_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final bool showSnackbar;

  LoginScreen({this.showSnackbar = false});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.showSnackbar) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account has been created! Please Login')),
        );
      });
    }
  }

  // Define the _login function here
  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProviderNotifier = ref.read(authProvider.notifier);

      // Use the AuthProvider to perform the login
      await authProviderNotifier.login(
        _emailController.text,
        _passwordController.text,
      );

      final authProviderState = ref.read(authProvider);

      // Check the authentication state and navigate accordingly
      if (authProviderState.token != null) {
        // Navigate to the TabScreen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => TabScreen()),
          (route) => false, // This removes all previous routes from the stack
        );
      } else {
        final snackBar = SnackBar(content: Text('Invalid email or password'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 10.0),
              height: 150.0, // specify the height
              width: 300.0, // specify the width
              child: Image.asset('assets/Logo.png'),
            ), // Replace with your logo asset
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!RegExp(
                                r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                            .hasMatch(value)) {
                          return 'Invalid email format';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true, // make the password hidden
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    GradientButton(
                      text: 'Login',
                      onPressed: () {
                        _login();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
