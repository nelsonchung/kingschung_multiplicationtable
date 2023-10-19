import 'package:flutter/material.dart';
import 'dart:math';

class TestPage extends StatefulWidget {
  final List<bool> isSelected;

  TestPage({required this.isSelected});

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  late int num1, num2, correctAnswer;
  late List<int> options;
  late List<Color> optionColors;

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    List<int> availableNumbers = [];
    for (int i = 2; i <= 9; i++) {
      if (widget.isSelected[i - 2]) availableNumbers.add(i);
    }

    // 如果沒有選擇的數字，就直接回傳
    if (availableNumbers.isEmpty) return;

    Random rand = Random();
    num1 = availableNumbers[rand.nextInt(availableNumbers.length)];
    num2 = availableNumbers[rand.nextInt(availableNumbers.length)];
    correctAnswer = num1 * num2;

    options = [
      correctAnswer,
      correctAnswer + rand.nextInt(10) + 1,
      //correctAnswer - rand.nextInt(10) - 1
    ];
    options.shuffle();

    // 重設顏色
    optionColors = [Colors.blue, Colors.blue, Colors.blue];
  }

  void _checkAnswer(int selectedOption) {
    for (int i = 0; i < options.length; i++) {
      if (options[i] == correctAnswer) {
        optionColors[i] = Colors.green;
      } else if (options[i] == selectedOption) {
        optionColors[i] = Colors.red;
      }
    }

    setState(() {});

    Future.delayed(Duration(seconds: 1), () {
      _generateQuestion();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow, // 設置背景顏色為黃色
      //appBar: AppBar(title: Text("考題")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('$num1 * $num2', style: TextStyle(fontSize: 200)),
            SizedBox(height: 160.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround, // 設置主軸上的空間分配
              children: options.asMap().entries.map((entry) {
                int idx = entry.key;
                int val = entry.value;
                return ElevatedButton(
                  onPressed: () => _checkAnswer(val),
                  style: ElevatedButton.styleFrom(primary: optionColors[idx]),
                  child: Text(val.toString(), style: TextStyle(fontSize: 100)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}