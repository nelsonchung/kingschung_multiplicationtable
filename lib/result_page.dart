import 'package:flutter/material.dart';
import 'main_page.dart';
import 'main.dart';
import 'before_test_setting_page.dart';
import 'device_utils.dart';

class ResultPage extends StatefulWidget {
  final int correctQuestions;
  final int totalQuestions;

  ResultPage(this.correctQuestions, this.totalQuestions);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool? isiPad;

  @override
  void initState() {
    super.initState();
    print("Enter initState");

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        isiPad = DeviceUtils.isIpad(context) ?? false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("結果", style: TextStyle(fontSize: 32)),
        backgroundColor: Colors.yellow,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BeforeTestSettingPage(),
              ),
            );
          },
        ),
      ),
      backgroundColor: Colors.yellow,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "你正確回答了 ${widget.correctQuestions} / ${widget.totalQuestions} 個問題！",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: isiPad! ? 60 : 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
