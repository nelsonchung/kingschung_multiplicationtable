import 'package:flutter/material.dart';
import 'dart:math';

class MultiplicationTablePage extends StatefulWidget {
  @override
  _MultiplicationTablePageState createState() =>
      _MultiplicationTablePageState();
}

class _MultiplicationTablePageState extends State<MultiplicationTablePage> {
  List<List<bool>> flippedCards = List.generate(9, (i) => List.filled(8, false));

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
      appBar: AppBar(
        title: Text("九九乘法表"),
        backgroundColor: Colors.yellow,
      ),
      backgroundColor: Colors.yellow,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,  // 添加此行
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isTablet(context) ? 68.0 : 48.0),
              child: Table(
                border: TableBorder.all(color: Colors.black),
                children: _generateTable(),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isTablet(context) ? 75.0 : 45.0),
            child: ElevatedButton.icon(
              onPressed: _resetTable,
              icon: Icon(Icons.refresh, size: 30),
              label: Text('重置', style: TextStyle(fontSize: 20)),
              style: ElevatedButton.styleFrom(
                primary: Colors.yellow, // 設置按鈕的背景色為黃色
                onPrimary: Colors.black, // 設置按鈕上文字和圖標的顏色
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _resetTable() {
    setState(() {
      flippedCards = List.generate(9, (i) => List.filled(8, false));
    });
  }

  List<TableRow> _generateTable() {
    List<TableRow> rows = [];
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
      Colors.pink,
      Colors.brown
    ];
    for (int j = 1; j <= 9; j++) {
      List<Widget> cols = [];
      for (int i = 2; i <= 9; i++) {
        cols.add(GestureDetector(
          onTap: () {
            setState(() {
              flippedCards[j - 1][i - 2] = !flippedCards[j - 1][i - 2];
            });
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 500),
            color: colors[i - 2],
            padding: EdgeInsets.all(isTablet(context) ? 12.0 : 6.0),
            child: Center(
              child: Text(
                flippedCards[j - 1][i - 2] ? '${i * j}' : '$i x $j',
                                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet(context) ? 20 : 8,  // 根据屏幕宽度设置字体大小
                  ),
              ),
            ),
          ),
        ));
      }
      rows.add(TableRow(children: cols));
    }
    return rows;
  }
}
