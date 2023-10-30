import 'package:flutter/material.dart';
import 'test_page.dart';
//import 'setting_page.dart';
import 'main_page.dart';
import 'multiplicationtable_page.dart';
import 'before_test_setting_page.dart';
import 'dart:io';
import 'dart:typed_data'; // 新增這一行來引入 Uint8List
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';

String? savedImagePath;  // 全域變數

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
        preferredCameraDevice: CameraDevice.front);

    if (image != null) {
      final File file = File(image.path);
      print("NelsonDBG: Image path: ${image.path}");  // 印出圖像路徑
      print("NelsonDBG: File size: ${await file.length()} bytes");  // 印出文件大小

      savedImagePath = image.path;
      ///* _saveImage失敗，under checking
      final savedPath = await _saveImage(file);
      setState(() {
        _imageFile = XFile(savedPath);
      });
      //*/
    }
  }

  Future<String> _saveImage(File imageFile) async {
    final Uint8List bytes = await imageFile.readAsBytes();
    
    print("NelsonDBG: Byte length: ${bytes.length}");  // 印出 Byte 長度
    
    final result = await ImageGallerySaver.saveImage(bytes);
    print("NelsonDBG: SaveImage Result: $result");  // 印出保存圖像的結果
    
    if (result['isSuccess'] == true) {
      if (result.containsKey('filePath') && result['filePath'] != null) {
        savedImagePath = result['filePath'];
        return savedImagePath!;
      } else {
        print('NelsonDBG: filePath is missing or null');
        throw Exception(
          'Failed to save the image because filePath is missing or null');
      }
    } else {
      print('NelsonDBG: Failed with errorMessage: ${result['errorMessage']}');
      throw Exception(
          'Failed to save the image. Reason: ${result['errorMessage']}');
    }
  }

  @override
  void initState() {
    super.initState();
    _imgFromCamera().then((_) {
      // 这将在获取图像后被调用
      if (_imageFile == null) {
        // 用户按下取消按钮，可以在这里处理退出应用程序的逻辑
        exit(0); // 使用exit函数退出应用程序
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainPage(),
          ),
        );
      }
    });
  }

  bool isTablet(BuildContext context) {
    // 獲得裝置的實際（邏輯）寬度和高度
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    // 獲得裝置的像素密度
    double pixelDensity = MediaQuery.of(context).devicePixelRatio;

    // 計算對角線長度
    double screenDiagonal = sqrt(width * width + height * height);

    // 計算實際的對角線尺寸（英寸）
    double screenDiagonalInches = screenDiagonal / (pixelDensity * 160);

    // 如果對角線尺寸大於 7 英寸，則通常被認為是平板
    return screenDiagonalInches >= 7.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  // 九九乘法表的動作
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MultiplicationTablePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.deepPurple, // 按鈕背景色
                  onPrimary: Colors.white, // 按鈕文字色
                  minimumSize: Size(200, 60),
                ),
                child: Text(
                  "九九乘法表",
                  style: TextStyle(fontSize: isTablet(context) ? 120: 40),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  // 進入挑戰的動作
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BeforeTestSettingPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.deepPurple, // 按鈕背景色
                  onPrimary: Colors.white, // 按鈕文字色
                  minimumSize: Size(200, 60),
                ),
                child: Text(
                  "進入挑戰",
                  style: TextStyle(fontSize: isTablet(context) ? 120: 40),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
