import 'test_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';

class BeforeTestSettingPage extends StatefulWidget {
  @override
  _BeforeTestSettingPageState createState() => _BeforeTestSettingPageState();
}

class _BeforeTestSettingPageState extends State<BeforeTestSettingPage> {
  int _selectedQuestions = 10;
  double _selectedTime = 0;
  late SharedPreferences _prefs;
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
      _selectedTime = _prefs.getDouble('time') ?? 0;
    });
  }

  _savePreferences() async {
    await _prefs.setInt('questions', _selectedQuestions);
    await _prefs.setDouble('time', _selectedTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("考題設定", style: TextStyle(fontSize: 32)),
        backgroundColor: Colors.yellow,
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
                    Text("$value", style: TextStyle(fontSize: 54)),
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
                  ],
                );
              }).toList(),
            ),
            SizedBox(height: 30),
            Text("選擇時間: ${_formatTime()}", style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold)),
            Container(
              height: MediaQuery.of(context).copyWith().size.height / 3,
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.ms,
                minuteInterval: 1,
                secondInterval: 1,
                initialTimerDuration: Duration(seconds: _selectedTime.toInt()),
                onTimerDurationChanged: (Duration duration) {
                  setState(() {
                    _selectedTime = duration.inSeconds.toDouble();
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
      _selectedTime = 0;
      _savePreferences();
    });
  }

  String _formatTime() {
    int minutes = (_selectedTime ~/ 60).toInt();
    int seconds = (_selectedTime % 60).toInt();
    return "$minutes 分 $seconds 秒";
  }
}
