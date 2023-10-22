import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:io';
import 'dart:async';

import 'main.dart';
import 'result_page.dart';

import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_tts/flutter_tts.dart';
//import 'package:audioplayers/audioplayers.dart';
import 'package:just_audio/just_audio.dart';

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
  late int answeredQuestions = 0;

  // Text to audio
  late FlutterTts flutterTts;
  //final player = AudioPlayer();
  //final AudioCache audioCache = AudioCache();
  //final assetsAudioPlayer = AssetsAudioPlayer();
  final player_correct = AudioPlayer();   
  final player_error = AudioPlayer();   

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    /*
    final duration_correct = player_correct.setUrl('asset: assets/audio/correct_sound_clap.mp3');
    final duration_error = player_error.setUrl('asset: assets/audio/error_sound_mock.mp3');
    final duration_correct = player_correct.setUrl('asset: audio/correct_sound_clap.mp3');
    final duration_error = player_error.setUrl('asset: audio/error_sound_mock.mp3');
    */
    final duration_correct = player_correct.setUrl('https://firebasestorage.googleapis.com/v0/b/groupbuying-9d07b.appspot.com/o/products%2Fcorrect_sound_clap.mp3?alt=media&token=f2f3e3dd-46f5-455c-a141-46a653c5d0b6&_gl=1*o34vfi*_ga*MjA4NjM0NDA0Ny4xNjkwMzg0NDky*_ga_CW55HF8NVT*MTY5Nzk0NzgxNS4xMTQuMS4xNjk3OTQ3OTA4LjQ5LjAuMA..');
    final duration_error = player_error.setUrl('https://firebasestorage.googleapis.com/v0/b/groupbuying-9d07b.appspot.com/o/products%2Ferror_sound_mock.mp3?alt=media&token=92c9c07b-1242-4981-8416-aa2d0ad1b7d7&_gl=1*1s16ehq*_ga*MjA4NjM0NDA0Ny4xNjkwMzg0NDky*_ga_CW55HF8NVT*MTY5Nzk0NzgxNS4xMTQuMS4xNjk3OTQ3OTU1LjIuMC4w');
    _loadPreferences().then((_) {
      _loadSettings();
      _readImageFileFromDisk();
      _startTimer(); // 啟動定時器
    });
  }

  // 新增一個方法來檢查是否達到問題上限
  void _checkCompletion() {
    if (completedQuestions >= totalQuestions) {
      _timer.cancel(); // 停止定時器
      //_timer.cancel();

      // 顯示AlertDialog
      /*
      showDialog(
        context: context,
        barrierDismissible: false, // 用戶必須點擊按鈕！
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('挑戰結束'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('您已完成所有問題。'),
                  Text('正確率-答案數/問題數：$correctQuestions/$totalQuestions'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('確認'),
                onPressed: () {
                  Navigator.of(context).pop();
                  // 這裡您可以添加導航到其他頁面的代碼
                },
              ),
            ],
          );
        },
      );
      */
      
      // 導航到結果頁面
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ResultPage(correctQuestions, totalQuestions)),
      );
      
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (currentIntervalTime > 0) {
          currentIntervalTime--;
        } else {
          _goToNextQuestion(); // 如果currentIntervalTime為0R，跳到下一個問題
        }
        if (completedQuestions >= totalQuestions) {
          timer.cancel();
        }
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

void _delay1secondstogeneratedQuestion() {
    Future.delayed(Duration(seconds: 1), () {
      if (completedQuestions < totalQuestions) {
        _generateQuestion();
        setState(() {});
      }
    });
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
} //_generateQuestion

  void _goToNextQuestion() {
    completedQuestions++;
    answeredQuestions++;  // 新增的

    // 將答案設為錯誤（因為用戶沒有回答）
    for (int i = 0; i < options.length; i++) {
      if (options[i] == correctAnswer) {
        optionColors[i] = Colors.green;
      } else {
        optionColors[i] = Colors.red;
      }
    }

    setState(() {});

  _delay1secondstogeneratedQuestion();

    // 檢查是否達到總問題數
    if (completedQuestions >= totalQuestions) {
      _timer.cancel();  // 停止定時器
      // 顯示結果
    }

    _checkCompletion();
  }

  void _checkAnswer(int selectedOption) {
    completedQuestions++;
    answeredQuestions++;  // 新增的

    for (int i = 0; i < options.length; i++) {
      if (options[i] == correctAnswer) {
        optionColors[i] = Colors.green;
      } else if (options[i] == selectedOption) {
        optionColors[i] = Colors.red;
      }
    }

    if (selectedOption == correctAnswer) {
      correctQuestions++;
      //使用 flutterTts speak
      //flutterTts.speak("Correct Answer");
      //flutterTts.speak("正確答案");
      player_correct.play();
      //player_correct.stop();
      //await player_correct.seek(Duration(second: 0));
    } else {
      //flutterTts.speak("Wrong Answer");
      //flutterTts.speak("答錯囉，加油");
      player_error.play();
      //player_error.stop();
    }

    setState(() {});

    _delay1secondstogeneratedQuestion();

    // 檢查是否達到總問題數
    if (completedQuestions >= totalQuestions) {
      _timer.cancel();  // 停止定時器
      // 顯示結果
    }

    _checkCompletion();
  }

  @override
  void dispose() {
    _timer.cancel();
    player_correct.dispose();
    player_error.dispose();
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
            Text('已回答問題數：$answeredQuestions/$totalQuestions', style: TextStyle(fontSize: 24)),  // 新增的
            //Text('已回答問題數：$answeredQuestions', style: TextStyle(fontSize: 24)),  // 新增的
            //Text('答題數目：$totalQuestions', style: TextStyle(fontSize: 24)),  // 更新這裡
            Text('間隔倒數時間：$currentIntervalTime 秒', style: TextStyle(fontSize: 24)),
            //Text('間隔時間：$intervalTime 秒', style: TextStyle(fontSize: 24)),  // 更新這裡
            if (currentImagePath != null)
              Image.file(
                File(currentImagePath!),
                width: 150,
                height: 150,
              ),
            Text('$num1 X $num2 = ?', style: TextStyle(fontSize: 120)),
            SizedBox(height: 50.0),
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
