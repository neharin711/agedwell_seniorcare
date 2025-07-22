import 'package:flutter/material.dart';

void main() {
  runApp(donation());
}

class donation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Donation Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DonationPage(),
    );
  }
}

class DonationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donate'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DonationAmountSection(),
            SizedBox(height: 20),
            DonationItemsSection(),
          ],
        ),
      ),
    );
  }
}

class DonationAmountSection extends StatelessWidget {
  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Donate by Amount',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter amount',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Handle donation by amount
                final amount = _amountController.text;
                print('Donate by amount: $amount');
              },
              child: Text('Donate'),
            ),
          ],
        ),
      ),
    );
  }
}

class DonationItemsSection extends StatelessWidget {
  final TextEditingController _itemsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Donate by Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _itemsController,
              decoration: InputDecoration(
                labelText: 'Enter items',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Handle donation by items
                final items = _itemsController.text;
                print('Donate by items: $items');
              },
              child: Text('Donate'),
            ),
          ],
        ),
      ),
    );
  }
}
