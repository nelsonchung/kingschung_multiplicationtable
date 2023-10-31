import 'package:flutter/material.dart';
import 'device_utils.dart';

class MultiplicationTablePage extends StatefulWidget {
  @override
  _MultiplicationTablePageState createState() =>
      _MultiplicationTablePageState();
}

class _MultiplicationTablePageState extends State<MultiplicationTablePage> {
  List<List<bool>> flippedCards = List.generate(9, (i) => List.filled(8, false));
  bool? isiPad;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        isiPad = DeviceUtils.isIpad(context);
      });
    });
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
              padding: EdgeInsets.all(isiPad! ? 68.0 : 48.0),
              child: Table(
                border: TableBorder.all(color: Colors.black),
                children: _generateTable(),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isiPad! ? 75.0 : 45.0),
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
            padding: EdgeInsets.all(isiPad! ? 12.0 : 6.0),
            child: Center(
              child: Text(
                flippedCards[j - 1][i - 2] ? '${i * j}' : '$i x $j',
                                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isiPad!? 20 : 8,  // 根据屏幕宽度设置字体大小
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
