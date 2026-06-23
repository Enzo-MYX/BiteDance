import 'package:flutter/material.dart';

class FilterNotificationScreen extends StatelessWidget {
  const FilterNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Filter & Notification"),
      ),
      body: const Center(
        child: Text(
          "Coming Soon",//haven't come up with the details yet
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
