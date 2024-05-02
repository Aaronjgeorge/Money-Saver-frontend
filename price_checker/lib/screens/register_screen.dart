import 'package:flutter/material.dart';
import 'package:price_checker/widgets/gradient_button.dart';
import 'package:http/http.dart' as http;
import 'package:price_checker/screens/login_screen.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Future<void> _signupUser(
    String fullName,
    String email,
    String mobile,
    String password,
    String confirmPassword,
    BuildContext context,
  ) async {
    final url =
        Uri.parse('https://money-saver-app-backend.onrender.com/auth/signup');

    try {
      final response = await http.post(
        url,
        body: {
          'name': fullName,
          'email': email,
          'mobile': mobile,
          'password': password
        },
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => LoginScreen(showSnackbar: true)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed')),
        );
      }
    } catch (e) {
      print('Error during login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 10.0),
                  height: 150.0,
                  width: 300.0,
                  child: Image.asset('assets/Logo.png'),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _fullNameController,
                        decoration: InputDecoration(labelText: 'Full Name'),
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: 'Email Address'),
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
                        controller: _phoneNumberController,
                        decoration: InputDecoration(labelText: 'Phone Number'),
                      ),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration:
                            InputDecoration(labelText: 'Enter New Password'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          } else if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration:
                            InputDecoration(labelText: 'Confirm New Password'),
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      GradientButton(
                        text: 'Continue',
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _signupUser(
                                _fullNameController.text,
                                _emailController.text,
                                _phoneNumberController.text,
                                _passwordController.text,
                                _confirmPasswordController.text,
                                context);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
