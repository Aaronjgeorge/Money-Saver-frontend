import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:price_checker/providers/expenses_provider.dart';
import 'package:price_checker/screens/receiptdetail_screen.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpensesScreen extends ConsumerWidget {
  Future<void> _openCamera(BuildContext context) async {
    final imagePicker = ImagePicker();
    final XFile? image =
        await imagePicker.pickImage(source: ImageSource.camera);

    if (image != null) {
      final croppedImage = await _cropImage(image.path);
      if (croppedImage != null) {
        final response = await _uploadImage(croppedImage, context);

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Receipt has been successfully processed!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Receipt processing failed')),
          );
          // Handle error uploading image
          // You can show a snackbar or display an error message to the user
        }
      }
    }
  }

  Future<void> _openGallery(BuildContext context) async {
    final imagePicker = ImagePicker();
    final XFile? image =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final croppedImage = await _cropImage(image.path);
      if (croppedImage != null) {
        final response = await _uploadImage(croppedImage, context);

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Receipt has been successfully processed!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Receipt processing failed')),
          );
          // You can show a snackbar or display an error message to the user
        }
      }
    }
  }

  Future<CroppedFile?> _cropImage(String imagePath) async {
    ImageCropper imageCropper = ImageCropper();
    CroppedFile? croppedFile = await imageCropper
        .cropImage(sourcePath: imagePath, aspectRatioPresets: [
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio16x9,
    ], uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: Colors.blue,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
      ),
    ]);
    return croppedFile;
  }

  Future<http.Response> _uploadImage(CroppedFile image, context) async {
    // Display a loading screen
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            height: 100, // Set your desired height
            width: 300, // Set your desired width
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(
                    height:
                        10), // Add some space between the CircularProgressIndicator and the text
                Text("Receipt is being scanned"),
              ],
            ),
          ),
        );
      },
    );
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? id = prefs.getString('userId');
    final uri = Uri.parse(
        'https://money-saver-app-backend.onrender.com/receipt/preprocessocr/${id}');
    var request = http.MultipartRequest('POST', uri);
    request.headers['Content-Type'] = 'multipart/form-data';
    request.files.add(http.MultipartFile.fromBytes(
        'image', await image.readAsBytes(),
        filename: 'image.jpg', contentType: MediaType('image', 'jpeg')));
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    // Dismiss the loading screen
    Navigator.pop(context);
    context.refresh(expensesProvider);

    return response;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expensesProvider);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 48, left: 25, bottom: 10),
            child: Text(
              'EXPENSES',
              style: TextStyle(
                fontSize: 36.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: expenses.when(
              data: (data) => data.isEmpty
                  ? Center(
                      child: Text('No expenses found. Please add an expense'))
                  : CustomScrollView(
                      slivers: <Widget>[
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              var sortedData = data.toList()
                                ..sort((a, b) {
                                  // Compare expenses based on the 'date' property in descending order
                                  DateTime dateA = DateTime.parse(a['date']);
                                  DateTime dateB = DateTime.parse(b['date']);
                                  return dateB.compareTo(dateA);
                                });

                              var expense = sortedData[index];
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 16.0),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        5.0), // Set the border radius
                                  ),
                                  elevation: 4.0,
                                  child: ListTile(
                                    leading: SizedBox(
                                      width: 60, // Set the width as needed
                                      child: Image.network(expense['imageUrl'],
                                          width: 50, height: 50),
                                    ),
                                    title: Text(expense['title'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        )),
                                    subtitle: Text(
                                      '${expense['category']} - ${DateFormat.yMMMd().format(DateTime.parse(expense['date']))}', // Format the date
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ReceiptDetailPage(
                                            id: expense['_id'],
                                            merchantName: expense['title'],
                                            date: expense['date'],
                                            currency: 'MYR',
                                            amount: expense['price'],
                                            description: 'Description here',
                                            category: expense['category'],
                                            paymentMethod:
                                                expense['paymentType'],
                                            receiptImagePath:
                                                expense['imageUrl'],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                            childCount: data.length,
                          ),
                        ),
                      ],
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _openGallery(context),
            child: Icon(Icons.photo),
            backgroundColor: Colors.green,
          ),
          SizedBox(height: 16.0), // Add spacing between the buttons
          FloatingActionButton(
            onPressed: () => _openCamera(context),
            child: Icon(Icons.camera_alt),
            backgroundColor: Colors.blue,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
