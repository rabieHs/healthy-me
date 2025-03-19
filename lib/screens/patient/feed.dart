import 'package:flutter/material.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Feed"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: GestureDetector(
              onTap: () {},
              child: Icon(Icons.notifications_outlined),
            ),
          )
        ],
        centerTitle: true,
      ),
      body: Center(
        child: Text("Feed"),
      ),
    );
  }
}
