import 'package:flutter/material.dart';
class NextPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Next Page'),
      ),
      body: Center(
        child: Text('Data fetched and saved to SharedPreferences.'),
      ),
    );
  }
}