import 'package:flutter/material.dart';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class TestPage extends StatefulWidget {
  TestPage(); 

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  late int num1, num2, correctAnswer;
  late List<int> options;
  late List<Color> optionColors;
  List<bool> isSelected = [];

  String? currentImagePath;

  late int remainingTime; // 剩餘時間（秒）
  late int totalQuestions; // 總問題數
  late int completedQuestions = 0; // 已完成問題數
  late int correctQuestions = 0; // 正確問題數
  late Timer _timer;
  //late Timer _remainingTimeTimer;  // 專門用於控制 remainingTime
  //late Timer _currentIntervalTimer;  // 專門用於控制 currentIntervalTime
  late int intervalTime;  // 間隔時間（秒）
  late int currentIntervalTime;


  @override
  void initState() {
    super.initState();
    _loadPreferences().then((_) {
      _loadSettings();
      _readImageFileFromDisk();
      _startTimer(); // 啟動定時器
    });
  }


  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
        } else {
          timer.cancel();
          // 顯示結果（您可以這裡顯示一個對話框或者導航到一個新的頁面）
        }
      });
    });
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalQuestions = prefs.getInt('questions') ?? 10;
      intervalTime = prefs.getDouble('time')?.toInt() ?? 0;  // 將間隔時間讀取到這裡
      // 為remainingTime設定一個合適的初始值，例如總問題數乘以間隔時間
      remainingTime = totalQuestions * intervalTime;  
    });
  }

  void _readImageFileFromDisk() async {
      final path = savedImagePath;  // 從 main.dart 中獲取
      print("saveImagePath is $savedImagePath");
      final File imageFile = File(path!);

      if (await imageFile.exists()) {
          setState(() {
              currentImagePath = path;  // 更新狀態變量
          });
      }
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    String? settings = prefs.getString('settings');
    if (settings != null) {
      List<bool> loadedSettings = settings
          .substring(1, settings.length - 1)
          .split(',')
          .map((e) => e.trim() == 'true')
          .toList();
      if (loadedSettings.length == 8) {
        setState(() {
          isSelected = loadedSettings;
          _generateQuestion(); // 這裡加載問題
        });
      }
    }
  }

void _generateQuestion() {
  // 取消前一個問題的 Timer（如果有的話）
  _timer.cancel();

  List<int> availableNumbers = [];
  for (int i = 2; i <= 9; i++) {
    if (isSelected[i - 2]) availableNumbers.add(i);
  }

  if (availableNumbers.isEmpty) return;

  Random rand = Random();
  num1 = availableNumbers[rand.nextInt(availableNumbers.length)];
  num2 = availableNumbers[rand.nextInt(availableNumbers.length)];
  correctAnswer = num1 * num2;

  options = [
    correctAnswer,
    correctAnswer + rand.nextInt(10) + 1,
  ];
  options.shuffle();

  optionColors = [Colors.blue, Colors.blue];

  setState(() {
    // 初始化當前間隔時間
    currentIntervalTime = intervalTime;
  });

  // 啟動一個新的 Timer 來倒數當前間隔時間
  _timer = Timer.periodic(Duration(seconds: 1), (timer) {
    setState(() {
      if (currentIntervalTime > 0) {
        currentIntervalTime--;
      } else {
        timer.cancel();
        _goToNextQuestion();
      }
    });
  });
}

  void _goToNextQuestion() {
    completedQuestions++;

    // 將答案設為錯誤（因為用戶沒有回答）
    for (int i = 0; i < options.length; i++) {
      if (options[i] == correctAnswer) {
        optionColors[i] = Colors.green;
      } else {
        optionColors[i] = Colors.red;
      }
    }

    setState(() {});

    Future.delayed(Duration(seconds: 1), () {
      _generateQuestion();
      setState(() {});
    });

    // 檢查是否達到總問題數
    if (completedQuestions >= totalQuestions) {
      _timer.cancel();  // 停止定時器
      // 顯示結果
    }
  }

  void _checkAnswer(int selectedOption) {
    completedQuestions++;
    if (selectedOption == correctAnswer) {
      correctQuestions++;
    }

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

    // 檢查是否達到總問題數
    if (completedQuestions >= totalQuestions) {
      _timer.cancel();  // 停止定時器
      // 顯示結果
    }  
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("開始挑戰，加油喔", style: TextStyle(fontSize: 32)),
        backgroundColor: Colors.yellow,
      ),
      backgroundColor: Colors.yellow,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //Text('剩餘時間：$remainingTime 秒', style: TextStyle(fontSize: 24)),  // 這裡是新添加的Widget
            Text('答題數目：$totalQuestions', style: TextStyle(fontSize: 24)),  // 更新這裡
            Text('間隔時間：$intervalTime 秒', style: TextStyle(fontSize: 24)),  // 更新這裡
            if (currentImagePath != null)
              Image.file(
                File(currentImagePath!),
                width: 300,
                height: 300,
              ),
            Text('$num1 X $num2 = ?', style: TextStyle(fontSize: 120)),
            SizedBox(height: 40.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: options.asMap().entries.map((entry) {
                int idx = entry.key;
                int val = entry.value;
                return ElevatedButton(
                  onPressed: () => _checkAnswer(val),
                  style: ElevatedButton.styleFrom(primary: optionColors[idx]),
                  child: Text(val.toString(), style: TextStyle(fontSize: 80)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
