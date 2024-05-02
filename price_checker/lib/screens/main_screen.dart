import 'package:flutter/material.dart';
import 'package:price_checker/widgets/gradient_button.dart';
import 'package:price_checker/screens/login_screen.dart';
import 'package:price_checker/screens/register_screen.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Align(
          alignment: Alignment.topCenter, // align the column to the top center
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 20.0),
                height: 200.0, // specify the height
                width: 300.0, // specify the width
                child: Image.asset('assets/Logo.png'),
              ),
              GradientButton(
                text: 'Login',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
              ),
              SizedBox(height: 20.0), // add space
              GradientButton(
                text: 'Register',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
