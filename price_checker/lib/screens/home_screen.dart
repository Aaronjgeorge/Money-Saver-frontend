import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchExpenses(), // Use the API call logic here
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Loading indicator while fetching data
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No data available');
        } else {
          final String name = snapshot.data!['name'];
          final List<Map<String, dynamic>> expenses =
              snapshot.data!['expenses'];
          final todaysExpenditure = calculateTodayExpenditure(expenses);

          return Scaffold(
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF404CCF),
                          Color(0xFF306CD9),
                          Color(0xFF1998E6),
                          Color(0xFF0BB4EF)
                        ], // Replace with your desired colors
                      ),
                    ), // Set the background color here
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding:
                              EdgeInsets.only(top: 48, left: 16, right: 16),
                          child: Text(
                            'Welcome back, $name!',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        Center(
                          child: Stack(
                            alignment: AlignmentDirectional.topCenter,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 25.0), // Add bottom padding here
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                        width: MediaQuery.of(context)
                                                .size
                                                .width *
                                            0.85, // 2/4th of the screen width
                                        height: 140,
                                        color: Colors.greenAccent[
                                            400] // adjust as needed
                                        // Add other properties as needed
                                        ),
                                  ),
                                ),
                              ),
                              Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Container(
                                  width: MediaQuery.of(context).size.width *
                                      0.90, // 3/4th of the screen width
                                  height: 130, // adjust as needed
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center, // Center vertically
                                      crossAxisAlignment: CrossAxisAlignment
                                          .center, // Center horizontall
                                      children: <Widget>[
                                        const Text(
                                          'TODAY\'S EXPENDITURE',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        Text(
                                          'RM ${todaysExpenditure.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Latest Expenses',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                  // Display the latest 3 expenses as horizontal cards
                  ...expenses.reversed
                      .take(3)
                      .map((expense) => ExpenseCard(expense: expense))
                      .toList(),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  // Function to fetch expenses from the API
  Future<Map<String, dynamic>> fetchExpenses() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? id = prefs.getString('userId');
      final String? name = prefs.getString('name');
      final url = Uri.parse(
          'https://money-saver-app-backend.onrender.com/receipt/receipts');
      final response = await http.post(
        url,
        body: {
          'id': id,
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<Map<String, dynamic>> expenses =
            data.map((expense) => Map<String, dynamic>.from(expense)).toList();
        return {'name': name ?? 'User', 'expenses': expenses};
      } else {
        throw Exception(
          'Failed to load expenses. Status code: ${response.statusCode}',
        );
      }
    } catch (error, stackTrace) {
      // Handle the error, log it, or rethrow if needed
      print('Error loading expenses: $error');
      print('Stack trace: $stackTrace');
      rethrow; // You can choose to rethrow the error after handling it
    }
  }

  // Function to calculate today's expenditure
  double calculateTodayExpenditure(List<Map<String, dynamic>> expenses) {
    final currentDate = DateTime.now();
    final todayExpenses = expenses.where((expense) {
      final expenseDate = DateTime.parse(expense['date']);
      return expenseDate.day == currentDate.day &&
          expenseDate.month == currentDate.month &&
          expenseDate.year == currentDate.year;
    });

    return todayExpenses.fold(
      0.0,
      (sum, expense) {
        final amount = expense['price'].toDouble();
        return sum + (amount);
      },
    );
  }
}

class ExpenseCard extends StatelessWidget {
  final Map<String, dynamic> expense;

  ExpenseCard({required this.expense});

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        DateFormat.yMMMd().format(DateTime.parse(expense['date']));
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title: ${expense['title']}', // Add this line
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Date: $formattedDate',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Amount: RM ${expense['price']}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
