import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:price_checker/screens/comparisonresults_screen.dart';
import 'package:price_checker/widgets/custom_button.dart';

class ViewItemsPage extends StatefulWidget {
  final String receiptId;

  ViewItemsPage({required this.receiptId});

  @override
  _ViewItemsPageState createState() => _ViewItemsPageState();
}

class _ViewItemsPageState extends State<ViewItemsPage> {
  late TextEditingController _itemNameController;
  late TextEditingController _itemPriceController;

  @override
  void initState() {
    super.initState();
    _itemNameController = TextEditingController();
    _itemPriceController = TextEditingController();
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchItemsByReceiptId(widget.receiptId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return Center(child: Text('No items found. Please add an item'));
            } else {
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 45, left: 25, bottom: 10),
                      child: Text(
                        'ITEMS',
                        style: TextStyle(
                          fontSize: 36.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        var item = snapshot.data![index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 4,
                          margin:
                              EdgeInsets.only(left: 16, right: 16, bottom: 16),
                          child: ListTile(
                            title: Text(
                              item['name'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Price: RM ${item['price']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomButton(
                                  color: Color(0xFF404CCF),
                                  onPressed: () {
                                    compareItem(
                                        context, item['name'], item['price']);
                                  },
                                  buttonText: 'Compare',
                                ),
                                SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    deleteItem(context, item['_id']);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.red,
                                  ),
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: snapshot.data!.length,
                    ),
                  ),
                ],
              );
            }
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return CircularProgressIndicator();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddItemModal(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddItemModal(BuildContext context) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height *
              0.85, // Adjust the height as needed
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _itemNameController,
                    decoration: InputDecoration(labelText: 'Item Name'),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _itemPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Item Price'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Add the new item and close the modal
                      addItem(context);
                    },
                    child: Text('Add Item'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> addItem(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('https://money-saver-app-backend.onrender.com/receipt/items'),
        body: {
          'receiptId': widget.receiptId,
          'name': _itemNameController.text,
          'price': _itemPriceController.text,
        },
      );

      if (response.statusCode == 200) {
        // Successful addition
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Item added successfully'),
            duration: Duration(seconds: 3),
          ),
        );

        // Clear the text fields
        _itemNameController.clear();
        _itemPriceController.clear();

        // Refresh the item list
        setState(() {});
      } else {
        // Handle error scenario
        print('Error adding item: ${response.statusCode}');
      }
    } catch (error) {
      // Handle general errors
      print('Error adding item: $error');
    }
    Navigator.pop(context); // Close the modal
  }

  Future<List<Map<String, dynamic>>> fetchItemsByReceiptId(
    String receiptId,
  ) async {
    final response = await http.get(
      Uri.parse(
          'https://money-saver-app-backend.onrender.com/receipt/items/$receiptId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('items')) {
        final List<dynamic> itemsData = responseData['items'];
        return List<Map<String, dynamic>>.from(itemsData);
      } else {
        throw Exception('Response does not contain the expected "items" key.');
      }
    } else {
      throw Exception('Failed to fetch items');
    }
  }

  Future<void> compareItem(
    BuildContext context,
    String itemName,
    dynamic itemPrice,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://money-saver-app-backend.onrender.com/receipt/items/compare'),
        body: {'itemName': itemName, 'itemPrice': '$itemPrice'},
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> comparisonResults =
            List<Map<String, dynamic>>.from(json.decode(response.body));

        // Navigate to a new screen to show the comparison results
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ComparisonResultsPage(
                comparisonResults: comparisonResults, price: itemPrice),
          ),
        );
        // rest of your code
      } else {
        print(response.statusCode);
        print('Error comparing item: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error comparing item. Please try again.'),
          ),
        );
      }
    } catch (e) {
      print('Error making API call: $e');
    }
  }

  Future<void> deleteItem(BuildContext context, String itemId) async {
    try {
      if (widget.receiptId == null) {
        // Handle the case where receiptId is null
        print('Error deleting item: receiptId is null');
        return;
      }

      final response = await http.delete(
        Uri.parse('https://money-saver-app-backend.onrender.com/receipt/items'),
        body: {
          'receiptId': widget.receiptId!,
          'itemId': itemId, // Convert itemId to String
        },
      );

      if (response.statusCode == 200) {
        // Successful deletion
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Item deleted successfully'),
            duration: Duration(seconds: 3),
          ),
        );

        // Refresh the item list
        setState(() {});
      } else {
        // Handle error scenario
        print('Error deleting item: ${response.statusCode}');
      }
    } catch (error) {
      // Handle general errors
      print('Error deleting item: $error');
    }
  }
}
