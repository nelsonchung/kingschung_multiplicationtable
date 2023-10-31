import 'package:flutter/material.dart';
import 'dart:io';
import 'test_page.dart';
import 'setting_page.dart';
import 'device_utils.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 1;
  late List<Widget> _children;
  bool? isiPad;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        isiPad = DeviceUtils.isIpad(context);
      });
    });
    _children = [
      TestPage(), // 傳遞 capturedImage 參數
      SettingPage(),
      // 如果有其他頁面，例如 SettingPage，請在此添加
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Color.fromARGB(255, 150, 232, 27),
        selectedItemColor: const Color.fromARGB(255, 250, 228, 23),
        unselectedItemColor: Color.fromARGB(255, 104, 129, 206),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: '挑戰',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
