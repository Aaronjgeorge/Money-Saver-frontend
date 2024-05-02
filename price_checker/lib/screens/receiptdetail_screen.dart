import 'dart:ffi';
import 'package:price_checker/screens/viewitems_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:price_checker/providers/expenses_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:price_checker/widgets/custom_button.dart';
import 'package:intl/intl.dart';

class ReceiptDetailPage extends ConsumerStatefulWidget {
  final String id;
  final String merchantName;
  final String date;
  final String currency;
  final dynamic amount;
  final String description;
  final String category;
  var paymentMethod;
  final String receiptImagePath;

  ReceiptDetailPage({
    required this.id,
    required this.merchantName,
    required this.date,
    required this.currency,
    required this.amount,
    required this.description,
    required this.category,
    required this.paymentMethod,
    required this.receiptImagePath,
  });

  @override
  _ReceiptDetailPageState createState() => _ReceiptDetailPageState();
}

class _ReceiptDetailPageState extends ConsumerState<ReceiptDetailPage> {
  bool _showFullImage = false; // Add this line to declare the variable

  List<String> paymentMethods = ['Cash', 'Card'];
  TextEditingController _merchantNameController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _currencyController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();
  TextEditingController _paymentMethodController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Set default values based on the values passed from the previous page
    _merchantNameController.text = widget.merchantName;
    _dateController.text =
        DateFormat.yMMMd().format(DateTime.parse(widget.date));
    _currencyController.text = widget.currency;
    _amountController.text = widget.amount.toDouble().toString();
    _categoryController.text = widget.category;
  }

  @override
  Widget build(BuildContext context) {
    String selectedPaymentMethod = widget.paymentMethod;
    if (!paymentMethods.contains(selectedPaymentMethod)) {
      selectedPaymentMethod = paymentMethods.first;
    }
    return Scaffold(
      // ... (unchanged code)
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Icon(Icons.arrow_back),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Receipt Details',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showFullImage = !_showFullImage;
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width *
                      0.95, // 3/4th of screen width
                  height: _showFullImage
                      ? 400
                      : 200, // Show 1/4th or full image based on _showFullImage
                  decoration: BoxDecoration(
                    color: Color(0xFFF69D34), // Background color
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      topRight: Radius.circular(15.0),
                    ),
                  ),
                  child: Center(
                    // Center the image within the container
                    child: Padding(
                      // Add padding to the image
                      padding:
                          const EdgeInsets.only(left: 16.0, right: 16, top: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15.0),
                          topRight: Radius.circular(15.0),
                        ),
                        child: Image.network(
                          widget.receiptImagePath,
                          width: MediaQuery.of(context).size.width *
                              1 *
                              0.5, // 2/4th of the container's width
                          fit: BoxFit
                              .cover, // To ensure the image fits within the container
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ListTile(
                title: Text(
                  'Merchant',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: TextFormField(
                  controller: _merchantNameController,
                  onChanged: (value) {
                    // Handle changes
                  },
                ),
              ),
            ),
            ListTile(
              title: Text(
                'Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: TextFormField(
                controller: _dateController,
                onChanged: (value) {
                  // Handle changes
                },
              ),
            ),
            ListTile(
              title: Text(
                'Currency Total',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Row(
                children: [
                  // Small text field for currency type
                  Container(
                    width: 50, // Adjust the width as needed
                    child: TextFormField(
                      controller: _currencyController,
                      // Assuming widget.currency is the currency type
                      onChanged: (value) {
                        // Handle changes if needed
                      },
                    ),
                  ),
                  SizedBox(width: 10), // Add some spacing between the fields
                  // Bigger text field for the amount
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      // Assuming widget.amount is the actual amount
                      onChanged: (value) {
                        // Handle changes if needed
                      },
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: TextFormField(
                onChanged: (value) {
                  // Handle changes
                },
              ),
            ),
            ListTile(
              title: Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: TextFormField(
                controller: _categoryController,
                onChanged: (value) {
                  // Handle changes
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: ListTile(
                title: Text(
                  'Method of Payment',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: DropdownButtonFormField<String>(
                  value: selectedPaymentMethod,
                  items: paymentMethods.map((String method) {
                    return DropdownMenuItem<String>(
                      value: method,
                      child: Text(method),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPaymentMethod = value!;
                    });
                  },
                ),
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomButton(
                      color: Color(0xFF404CCF),
                      onPressed: () {
                        // Action to edit receipt
                        _editReceipt(context, ref);
                      },
                      buttonText: 'Edit Receipt',
                    ),
                    CustomButton(
                      color: Color(0xFF404CCF),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ViewItemsPage(receiptId: widget.id),
                          ),
                        );
                      },
                      buttonText: 'View Items',
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: CustomButton(
                      color: Colors.red,
                      onPressed: () {
                        // Action to delete receipt
                        _deleteReceipt(context, ref);
                      },
                      buttonText: 'Delete Receipt',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editReceipt(BuildContext context, WidgetRef ref) async {
    try {
      final response = await http.put(
        Uri.parse(
            'https://money-saver-app-backend.onrender.com/receipt/${widget.id}'),
        body: {
          'title': _merchantNameController.text,
          'date': _dateController.text,
          'currency': _currencyController.text,
          'price': _amountController.text,
          'category': _categoryController.text,
          'paymentType': widget.paymentMethod, // Use the current payment method
        },
      );

      if (response.statusCode == 200) {
        // Successful edit
        // Show success message using SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Receipt edited successfully'),
            duration: Duration(seconds: 3),
          ),
        );

        // Trigger a refresh after editing
        ref.refresh(expensesProvider);
      } else {
        // Handle error scenario
        print('Error editing receipt: ${response.statusCode}');
      }
    } catch (error) {
      // Handle general errors
      print('Error editing receipt: $error');
    }
  }

  void _deleteReceipt(BuildContext context, WidgetRef ref) async {
    try {
      // Replace the following with the actual API endpoint
      final response = await http.delete(
        Uri.parse(
            'https://money-saver-app-backend.onrender.com/receipt/receipt/${widget.id}'),
      );

      if (response.statusCode == 200) {
        // Successful deletion
        // You can handle the success scenario here

        // Trigger a refresh after deletion
        ref.refresh(expensesProvider);

        // After deletion, navigate back to the previous screen
        Navigator.pop(context);
      } else {
        // Handle error scenario
        print('Error deleting receipt: ${response.statusCode}');
      }
    } catch (error) {
      // Handle general errors
      print('Error deleting receipt: $error');
    }
  }
}
