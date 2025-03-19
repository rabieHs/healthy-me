import 'package:flutter/material.dart';
import 'package:flutter_applicatione/screens/patient/quiz_page.dart';

import '../../models/question.dart';

class ActivitiesTab extends StatelessWidget {
  const ActivitiesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test"),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Quiz2(
                            questionList: getGAD7question(),
                            questionType: 'gad7',
                          )),
                );
              },
              child: const Text('Anxiety'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Quiz2(
                          questionList: getPHQ9question(),
                          questionType: 'phq9')),
                );
              },
              child: const Text('Depression'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Quiz2(
                          questionList: getPSSquestion(), questionType: 'pss')),
                );
              },
              child: const Text('Stress'),
            ),
          ],
        ),
      ),
    );
  }
}
