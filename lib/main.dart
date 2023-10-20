import 'package:flutter/material.dart';
import 'test_page.dart';
import 'setting_page.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
  XFile? _imageFile;
  int _currentIndex = 0;
  List<bool> isSelected = [true, true, true, true, true, true, true, true];
  late List<Widget> _children;

  final ImagePicker _picker = ImagePicker();

  _imgFromCamera() async {

    XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
      preferredCameraDevice: CameraDevice.front
    );

    setState(() {
      _imageFile = image;
    });

    // 新增這一行來更新TestPage
    _children[0] = TestPage(isSelected: isSelected, capturedImage: _imageFile);
  }

  @override
  void initState() {
    super.initState();
    _imgFromCamera();
    _children = [
      TestPage(isSelected: isSelected, capturedImage: _imageFile),
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
