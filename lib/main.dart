import 'package:flutter/material.dart';
import 'setting_page.dart';
import 'test_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  // 初始化isSelected列表
  List<bool> isSelected = [true, true, true, true, true, true, true, true];

  late List<Widget> _children; // 移除final標記

  _MyHomePageState() {
    _children = [
      TestPage(isSelected: isSelected),
      SettingPage(), // 如果SettingPage也需要這個列表，您可以傳遞它
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Color.fromARGB(255, 150, 232, 27),
        selectedItemColor: const Color.fromARGB(255, 250, 228, 23), // 選中的項目顏色
        unselectedItemColor: Color.fromARGB(255, 104, 129, 206), // 未選中的項目顏色
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: '考試',
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
