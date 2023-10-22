import 'test_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'main.dart';

class BeforeTestSettingPage extends StatefulWidget {
  @override
  _BeforeTestSettingPageState createState() => _BeforeTestSettingPageState();
}

class _BeforeTestSettingPageState extends State<BeforeTestSettingPage> {
  int _selectedQuestions = 10;
  double _selectedTime = 5;
  late SharedPreferences _prefs;
  ValueKey<int> _pickerKey = ValueKey<int>(0);  // 新增一個ValueKey
  List<bool> isSelected = List.generate(8, (index) => true);

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadSettings();
  }

  _loadSettings() async {
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
      }
    }
  }

  _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedQuestions = _prefs.getInt('questions') ?? 10;
      _selectedTime = _prefs.getDouble('time') ?? 5;
      _pickerKey = ValueKey<int>(_selectedTime.toInt());  // 更新Key的值
    });
  }

  _savePreferences() async {
    await _prefs.setInt('questions', _selectedQuestions);
    await _prefs.setDouble('time', _selectedTime);
  }

  @override
  Widget build(BuildContext context) {
    int minutes = (_selectedTime ~/ 60).toInt();  // 從 _selectedTime 提取分鐘
    int seconds = (_selectedTime % 60).toInt();  // 從 _selectedTime 提取秒數
    
    return Scaffold(
      appBar: AppBar(
        title: Text("考題設定", style: TextStyle(fontSize: 32)),
        backgroundColor: Colors.yellow,
        leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MyHomePage(), // 你要跳轉的特定頁面
            ),
          );
        },
      ),
    ),      
      backgroundColor: Colors.yellow,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("題數", style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [10, 20, 30].map((int value) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<int>(
                      value: value,
                      groupValue: _selectedQuestions,
                      onChanged: (int? newValue) {
                        setState(() {
                          _selectedQuestions = newValue!;
                          _savePreferences();
                        });
                      },
                    ),
                    Text("$value", style: TextStyle(fontSize: 54)),
                  ],
                );
              }).toList(),
            ),
            SizedBox(height: 30),
            Text("答題間隔時間(至少5秒): ${_formatTime()}", style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold)),
            Container(
              height: MediaQuery.of(context).copyWith().size.height / 3,
              child: CupertinoTimerPicker(
                key: _pickerKey,  // 使用Key來強制重新構建CupertinoTimerPicker
                mode: CupertinoTimerPickerMode.ms,
                minuteInterval: 1,
                secondInterval: 1,
                initialTimerDuration: Duration(minutes: minutes, seconds: seconds),  // 使用分鐘和秒數
                onTimerDurationChanged: (Duration duration) {
                  setState(() {
                    // 檢查選擇的時間是否低於5秒
                    if (duration.inSeconds < 5) {
                      _selectedTime = 5.0;  // 如果是，則將時間設置為5秒
                    } else {
                      _selectedTime = (duration.inMinutes * 60).toDouble() + duration.inSeconds.toDouble();
                    }
                    _savePreferences();
                  });
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToTestPage,
              style: ElevatedButton.styleFrom(
                primary: Colors.deepPurple,
                onPrimary: Colors.white,
                minimumSize: Size(200, 60),
              ),
              child: Text("開始計時", style: TextStyle(fontSize: 30)),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _resetTime,
              style: ElevatedButton.styleFrom(
                primary: Colors.deepPurple,
                onPrimary: Colors.white,
                minimumSize: Size(200, 60),
              ),
              child: Text("重置", style: TextStyle(fontSize: 24)),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTestPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TestPage()),
    );
  }

  void _resetTime() {
    setState(() {
      _selectedTime = 5;
      _savePreferences();
    });
  }

  String _formatTime() {
    int minutes = (_selectedTime ~/ 60).toInt();
    int seconds = (_selectedTime % 60).toInt();
    return "$minutes 分 $seconds 秒";
  }
}
