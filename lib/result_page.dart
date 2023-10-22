import 'package:flutter/material.dart';
import 'main_page.dart';
import 'main.dart';
import 'before_test_setting_page.dart';

class ResultPage extends StatelessWidget {
  final int correctQuestions;
  final int totalQuestions;

  ResultPage(this.correctQuestions, this.totalQuestions);

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
              builder: (context) => BeforeTestSettingPage(), // 你要跳轉的特定頁面
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
            Text("你正確回答了 $correctQuestions / $totalQuestions 個問題！", style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold)),
            //style: TextStyle(fontSize: 120)),
            ElevatedButton(
              onPressed: () {
                //Navigator.pop(context); // 返回上一頁
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      //builder: (context) => MainPage()),
                      //builder: (context) => MyHomePage()),
                      builder: (context) => BeforeTestSettingPage()),
                );
              },
              child: Text('返回主畫面'),
            )
          ],
        ),
      ),
    );
  }
}
