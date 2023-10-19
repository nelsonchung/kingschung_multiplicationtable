import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  List<bool> isSelected = List.generate(8, (index) => true); // 預設為全部選中

  @override
  void initState() {
    super.initState();
    _loadSettings(); // 在 initState 中加載設定
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

  _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('settings', isSelected.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow, // 設置背景顏色為黃色
      //appBar: AppBar(title: Text('設定', style: TextStyle(fontSize: 80))), // 調整字體大小
      //appBar: AppBar(title: Text("設定")),
      body: Center(
        child: ToggleButtons(
          children: [
            for (int i = 2; i <= 9; i++)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('$i', style: TextStyle(fontSize: 80)), // 調整字體大小
              ),
          ],
          isSelected: isSelected,
          onPressed: (int index) {
            setState(() {
              isSelected[index] = !isSelected[index];
              _saveSettings();
            });
          },
        ),
      ),
    );
  }
}
