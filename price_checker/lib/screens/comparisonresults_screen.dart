import 'package:flutter/material.dart';

class ComparisonResultsPage extends StatelessWidget {
  final List<Map<String, dynamic>> comparisonResults;
  final dynamic price;
  ComparisonResultsPage({required this.comparisonResults, required this.price});

  @override
  Widget build(BuildContext context) {
    if (comparisonResults.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text('No similar items found'),
        ),
      );
    } else {
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 45.0, left: 16.0),
                child: Text(
                  'Comparison Results',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 20.0),
                // child: Text(
                //   "Purchased Price: RM ${price.toString()}",
                //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                //   textAlign: TextAlign.left,
                // ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  var result = comparisonResults[index];
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 2.5, horizontal: 16.0),
                    child: Card(
                      child: Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: Text(result['itemName'] ?? 'N/A'),
                              subtitle: Text(result['priceText'] ?? 'N/A'),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(right: 10.0),
                            height: 30.0, // specify the height
                            width: 30.0, // specify the width
                            child: Image.asset(
                              result['website'] == 'Aeon'
                                  ? 'assets/aeon-logo.png'
                                  : result['website'] == 'Jaya Grocer'
                                      ? 'assets/jaya-logo.png'
                                      : 'assets/default.png',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: comparisonResults.length,
              ),
            ),
          ],
        ),
      );
    }
  }
}
