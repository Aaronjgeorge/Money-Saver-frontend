import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:price_checker/providers/login_provider.dart'; // Replace with the actual path
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'dart:convert'; // Import dart:convert
import 'package:price_checker/widgets/gradient_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends ConsumerStatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  File? _pickedImage;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImageToApi(
      BuildContext context,
      String id,
      File? imageFile,
      String name,
      String email,
      String mobile,
      String password,
      String confirmPassword,
      WidgetRef ref) async {
    final url =
        'https://money-saver-app-backend.onrender.com/auth/updateProfile/$id';
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers['Content-Type'] = 'multipart/form-data';

    if (name.isNotEmpty) {
      request.fields['name'] = name;
    }
    if (email.isNotEmpty) {
      request.fields['email'] = email;
    }
    if (mobile.isNotEmpty) {
      request.fields['mobile'] = mobile;
    }
    if (password.isNotEmpty) {
      request.fields['password'] = password;
    }
    if (confirmPassword.isNotEmpty) {
      request.fields['confirmPassword'] = confirmPassword;
    }

    if (imageFile != null) {
      List<int> imageBytes = await imageFile.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes('image', imageBytes,
          filename: 'image.jpg', contentType: MediaType('image', 'jpeg')));
    }

    final response = await request.send();
    String message;
    if (response.statusCode == 200) {
      final http.Response res = await http.Response.fromStream(response);

      // Parse the response body as JSON
      final Map<String, dynamic> responseData = json.decode(res.body);
      final user = responseData['user'];

      // Now you can access the properties of the 'User' object
      final name = user['name'];
      final mobile = user['mobile'];
      final email = user['email'];
      final imageUrl = user['imageUrl'];
      message = 'Profile updated successfully';
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('name', name);
      prefs.setString('email', email);
      prefs.setString('mobile', mobile);
      prefs.setString('imageUrl', imageUrl);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } else {
      message = 'Profile update failed';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = ref.read(authProvider.notifier);

    return FutureBuilder<Map<String, String?>>(
      future: authNotifier.loadUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final userData = snapshot.data!;
          // Set the initial values for the TextEditingController
          _fullNameController.text = userData['name'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _phoneNumberController.text = userData['mobile'] ?? '';

          return Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 50.0, left: 16, right: 16),
              child: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: (_pickedImage != null
                            ? FileImage(_pickedImage!)
                            : NetworkImage(userData['imageUrl'] ??
                                    'https://static.vecteezy.com/system/resources/thumbnails/020/911/740/small/user-profile-icon-profile-avatar-user-icon-male-icon-face-icon-profile-icon-free-png.png')
                                as ImageProvider<Object>),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          backgroundColor: Colors.blue[300],
                          radius: 20,
                          child: IconButton(
                            icon: Icon(Icons.camera_alt, size: 20),
                            color: Colors.black,
                            onPressed: () async {
                              await _pickImage();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Add TextFormField for each field
                  TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(labelText: 'Full Name'),
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email Address'),
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
                  ),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Confirm Password'),
                  ),
                  SizedBox(height: 20),
                  GradientButton(
                    text: "Update",
                    onPressed: () {
                      _uploadImageToApi(
                        context,
                        userData['id']!,
                        _pickedImage,
                        _fullNameController.text,
                        _emailController.text,
                        _phoneNumberController.text,
                        _passwordController.text,
                        _confirmPasswordController.text,
                        ref,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
