import 'package:flutter/material.dart';
import 'package:price_checker/screens/profile_screen.dart';
import 'package:price_checker/screens/settings_screen.dart';
import 'package:price_checker/screens/main_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 48, left: 25, bottom: 10),
          child: Text(
            'ACCOUNT',
            style: TextStyle(
              fontSize: 36.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            elevation: 4,
            child: ListTile(
              title: const Text('Profile',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfilePage()));
              },
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            elevation: 4,
            child: ListTile(
              title: const Text('App Settings',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingsPage()));
                // Navigate to app settings
              },
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            elevation: 4,
            child: ListTile(
              title: const Text('Logout',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
              onTap: () async {
                // Set loggedIn state to false
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                prefs.setBool('_loggedIn', false);

                // Navigate to MainScreen
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()),
                  (route) =>
                      false, // This removes all previous routes from the stack
                );
              },
            ),
          ),
        ),
      ],
    ));
  }
}
