import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:io';
import 'dart:async';

import 'main.dart';
import 'result_page.dart';

//import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_tts/flutter_tts.dart';
//import 'package:audioplayers/audioplayers.dart';
import 'package:just_audio/just_audio.dart';

import 'device_utils.dart';

class TestPage extends StatefulWidget {
  TestPage(); 

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  int num1=9, num2=9, correctAnswer=0;
  List<int> options = [5, 5];
  List<Color> optionColors = [Colors.blue, Colors.blue];
  List<bool> isSelected = [];

  String? currentImagePath;

  int remainingTime = 5; // 剩餘時間（秒）
  int totalQuestions = 10; // 總問題數
  int completedQuestions = 0; // 已完成問題數
  int correctQuestions = 0; // 正確問題數
  Timer? _timer;
  //late Timer _remainingTimeTimer;  // 專門用於控制 remainingTime
  //late Timer _currentIntervalTimer;  // 專門用於控制 currentIntervalTime
  late int intervalTime;  // 間隔時間（秒）
  late int currentIntervalTime = 5;
  late int answeredQuestions = 0;

  // Text to audio
  late FlutterTts flutterTts;
  final audioPlayer = AudioPlayer();

  // Device types
  bool isiPad = false;  // 初始化為false或true，根據您的需求

  @override
  void initState() {
    print("Enter initState");
    super.initState();
    
    // Init the flutter tts
    flutterTts = FlutterTts();
    
    // Init the device types
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        isiPad = DeviceUtils.isIpad(context) ?? false;
      });
    });

    // Load the preferences
    _loadPreferences().then((_) {
      _loadSettings();
      _readImageFileFromDisk();
      //_generateQuestion();  // Generate the first question here
      _startTimer();        // Start timer after generating the question
    }); 
  }


  // 新增一個方法來檢查是否達到問題上限
  void _checkCompletion() {
    print("Enter _checkCompletion");
    if (completedQuestions >= totalQuestions) {
      _timer!.cancel(); // 停止定時器
      // 導航到結果頁面
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ResultPage(correctQuestions, totalQuestions)),
      );
    }
  }

  void _startTimer() {
    print("Enter _startTimer");
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (currentIntervalTime > 0) {
          currentIntervalTime--;
        } else {
          _goToNextQuestion();
        }
        if (completedQuestions >= totalQuestions || remainingTime <= 0) {
          timer.cancel();
        } else {
          remainingTime--;
        }
      });
    });
  }

  Future<void> _loadPreferences() async {
    print("Enter _loadPreferences");
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalQuestions = prefs.getInt('questions') ?? 10;
      intervalTime = prefs.getDouble('time')?.toInt() ?? 0;  // 將間隔時間讀取到這裡
      // 為remainingTime設定一個合適的初始值，例如總問題數乘以間隔時間
      remainingTime = totalQuestions * intervalTime;  
    });
  }

  void _readImageFileFromDisk() async {
    print("Enter _readImageFileFromDisk");
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
  print("Enter _loadSettings");
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
      });
    } else {
      print('Invalid settings length in SharedPreferences. Using default values.');
      isSelected = List<bool>.filled(8, true); // Default values
    }
  } else {
    print('Settings not found in SharedPreferences. Using default values.');
    isSelected = List<bool>.filled(8, true); // Default values
  }

  // Only call _generateQuestion if isSelected is not empty
  if (isSelected.isNotEmpty) {
    _generateQuestion();
  }
}

void _delay1secondstogeneratedQuestion() {
  print("Enter _delay1secondstogeneratedQuestion");
    Future.delayed(Duration(seconds: 1), () {
      if (completedQuestions < totalQuestions) {
        _generateQuestion();
      }
    });
  }

void _generateQuestion() {
  print('開始生成問題...');

  // 取消前一個問題的 Timer（如果有的話）
  if (_timer?.isActive ?? false) {
    print('取消前一個問題的 Timer');
    _timer!.cancel();
  }

  print('Announcement availableNumbers');
  List<int> availableNumbers = [];
  print('Values of isSelected: $isSelected');  // Log the values of isSelected
  print('可用的數字 (before processing): $availableNumbers');
  for (int i = 2; i <= 9; i++) {
    if (isSelected[i - 2]) availableNumbers.add(i);
  }
  print('可用的數字 PartII (after processing): $availableNumbers');

  if (availableNumbers.isEmpty) {
    print('沒有選擇任何數字，使用默認的數字範圍');
    availableNumbers = List<int>.generate(8, (index) => index + 2); // 使用默認的數字範圍2-9
    print('Available numbers after default values: $availableNumbers');  // Log after adding default values
  }

  print('開始產生random餐處');
  Random rand = Random();
  num1 = availableNumbers[rand.nextInt(availableNumbers.length)];
  num2 = availableNumbers[rand.nextInt(availableNumbers.length)];
  print('選擇的兩個數字：$num1 和 $num2');

  correctAnswer = num1 * num2;
  print('正確答案：$correctAnswer');

  options = [
    correctAnswer,
    correctAnswer + rand.nextInt(10) + 1,
  ];
  print('選項（未打亂）：$options');
  options.shuffle();
  print('選項（打亂後）：$options');

  optionColors = [Colors.blue, Colors.blue];
  print('選項顏色設置完成');

  setState(() {
    // 初始化當前間隔時間
    currentIntervalTime = intervalTime;
    print('初始化當前間隔時間：$currentIntervalTime');
  });

  // 啟動一個新的 Timer 來倒數當前間隔時間
  _timer = Timer.periodic(Duration(seconds: 1), (timer) {
    setState(() {
      if (currentIntervalTime > 0) {
        currentIntervalTime--;
        print('當前間隔時間：$currentIntervalTime');
      } else {
        print('時間到！進入下一個問題');
        timer.cancel();
        _goToNextQuestion();
      }
    });
  });
}

  void _goToNextQuestion() {
    print('進入到_goToNextQuestion');
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
      _timer!.cancel();  // 停止定時器
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

      // URL source: https://firebasestorage.googleapis.com/v0/b/groupbuying-9d07b.appspot.com/o/products%2Fcorrect_sound_clap_0_4.mp3?alt=media&token=1c807127-295b-4a6e-bbdf-0612f2acde85&_gl=1*jkdemm*_ga*MjA4NjM0NDA0Ny4xNjkwMzg0NDky*_ga_CW55HF8NVT*MTY5Nzk4MjI0OS4xMTUuMS4xNjk3OTgyNTIzLjUzLjAuMA..
      final duration = audioPlayer.setUrl('https://firebasestorage.googleapis.com/v0/b/groupbuying-9d07b.appspot.com/o/products%2Fcorrect_sound_clap_0_4.mp3?alt=media&token=1c807127-295b-4a6e-bbdf-0612f2acde85&_gl=1*jkdemm*_ga*MjA4NjM0NDA0Ny4xNjkwMzg0NDky*_ga_CW55HF8NVT*MTY5Nzk4MjI0OS4xMTUuMS4xNjk3OTgyNTIzLjUzLjAuMA..');
      audioPlayer.play();
    } else {
      //使用 flutterTts speak
      //flutterTts.speak("Wrong Answer");
      //flutterTts.speak("答錯囉，加油");

      final duration = audioPlayer.setUrl('https://firebasestorage.googleapis.com/v0/b/groupbuying-9d07b.appspot.com/o/products%2Ferror_sound_mock.mp3?alt=media&token=92c9c07b-1242-4981-8416-aa2d0ad1b7d7&_gl=1*1n2gdvg*_ga*MjA4NjM0NDA0Ny4xNjkwMzg0NDky*_ga_CW55HF8NVT*MTY5Nzk4MjI0OS4xMTUuMS4xNjk3OTgyMjk5LjEwLjAuMA..');
      audioPlayer.play();
    }

    setState(() {});

    _delay1secondstogeneratedQuestion();

    // 檢查是否達到總問題數
    if (completedQuestions >= totalQuestions) {
      _timer!.cancel();  // 停止定時器
      // 顯示結果
    }

    _checkCompletion();
  }

  @override
  void dispose() {
    _timer!.cancel();
    //player_correct.dispose();
    //player_error.dispose();
    audioPlayer.stop();
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
            Text('已回答問題數：$answeredQuestions/$totalQuestions', style: TextStyle(fontSize: isiPad! ? 24 : 22)),  // 新增的
            //Text('已回答問題數：$answeredQuestions', style: TextStyle(fontSize: 24)),  // 新增的
            //Text('答題數目：$totalQuestions', style: TextStyle(fontSize: 24)),  // 更新這裡
            Text('間隔倒數時間：$currentIntervalTime 秒', style: TextStyle(fontSize: isiPad! ? 24: 22)),
            //Text('間隔時間：$intervalTime 秒', style: TextStyle(fontSize: 24)),  // 更新這裡
            if (currentImagePath != null)
              Image.file(
                File(currentImagePath!),
                width: 150,
                height: 150,
              ),
            Text('$num1 X $num2 = ?', style: TextStyle(fontSize: isiPad! ? 120 : 80)),
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
