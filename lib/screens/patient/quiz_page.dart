import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'dart:math' as math;

import '../../models/question.dart';
import '../../services/analyse_serices.dart';
import '../../services/question_services.dart';

class Quiz2 extends StatefulWidget {
  final List<Question> questionList;
  final String questionType;
  const Quiz2(
      {super.key, required this.questionList, required this.questionType});

  @override
  State<Quiz2> createState() => _Quiz2State();
}

class _Quiz2State extends State<Quiz2> {
  int currentIndex = 0;
  int Score = 0;
  Answer? selectedAnswer;
  List<int> scoreList = [];

  void _changeAnswer(Answer answer) {
    if (selectedAnswer != null) {
      Score -= selectedAnswer!.score;
      scoreList.removeLast();
    }
    setState(() {
      selectedAnswer = answer;
      Score += answer.score;
      scoreList.add(answer.score);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            _questionWidget(),
            SizedBox(
              height: 50,
            ),
            _nswersWidget(),
            SizedBox(
              height: 50,
            ),
            _nextButton()
          ],
        ),
      ),
    );
  }

  Widget _nextButton() {
    return GestureDetector(
        child: ElevatedButton(
      onPressed: () async {
        setState(() {
          currentIndex = (currentIndex + 1) % widget.questionList.length;
          selectedAnswer = null;
        });
        if (currentIndex == 0) {
          final AnalyseServices analyseServices = AnalyseServices();

          String output = QuestionServices()
              .getscore(Score, widget.questionType, scoreList);
          String testType = "";
          switch (widget.questionType) {
            case 'phq9':
              testType = "Despression";

            case 'gad7':
              testType = "Anxiety";

            case 'pss':
              testType = "Stress";

            case 'dass21':
              testType = "general";
          }

          analyseServices.checkAndUpdateUserMood(output, testType);

          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Result"),
                  content: Text(output),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text("OK"),
                    )
                  ],
                );
              });

          print("output $output");
        }
      },
      child: Text("Next"),
    ));
  }

  _nswersWidget() {
    return Column(
      children: widget.questionList[currentIndex].answers
          .map((e) => _answerButton(e))
          .toList(),
    );
  }

  Widget _answerButton(Answer answer) {
    bool isSelected = answer == selectedAnswer;
    return GestureDetector(
      onTap: () {
        _changeAnswer(answer);
      },
      child: Container(
          width: double.infinity,
          height: 40,
          margin: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: isSelected == true ? Colors.blue : Colors.grey,
              ),
              borderRadius: BorderRadiusDirectional.circular(10)),
          child: Center(
            child: Text(
              answer.answerText,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          )),
    );
  }

  _questionWidget() {
    return Column(
      children: [
        Text("Question ${currentIndex + 1} "),
        SizedBox(
          height: 5,
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          width: double.infinity,
          child: Text(
            widget.questionList[currentIndex].questionText,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }
}
