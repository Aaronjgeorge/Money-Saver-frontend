import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final expensesProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? id = prefs.getString('userId');
  try {
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
      return data.map((expense) => Map<String, dynamic>.from(expense)).toList();
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
});
