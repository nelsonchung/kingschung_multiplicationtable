// multiplicationtable_page.dart
import 'package:flutter/material.dart';

class MultiplicationTablePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("九九乘法表"),
        backgroundColor: Colors.yellow, // 將AppBar的背景色設為黃色
      ),
      backgroundColor: Colors.yellow,  // 黃色背景
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(54.0),
          child: Table(
            border: TableBorder.all(color: Colors.black),
            children: _generateTable(),
          ),
        ),
      ),
    );
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
      // 將外層循環改為j
      List<Widget> cols = [];
      for (int i = 2; i <= 9; i++) {
        // 將內層循環改為i
        cols.add(Container(
          //color: colors[(i + j) % colors.length], // 使用不同的顏色來呈現, 呈現的結果會是以斜線為同一個顏色的方式作呈現
          color: colors[i - 2],  // 使用 i - 2 作為索引來選擇顏色
          padding: EdgeInsets.all(12.0),
          child: Center(
            child: Text(
              '$i x $j = ${i * j}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ));
      }
      rows.add(TableRow(children: cols));
    }
    return rows;
  }

}
