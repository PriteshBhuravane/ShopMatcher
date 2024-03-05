import 'package:flutter/material.dart';


class ZIndexExample extends StatefulWidget {
  @override
  _ZIndexExampleState createState() => _ZIndexExampleState();
}

class _ZIndexExampleState extends State<ZIndexExample> {
  int stackIndex = 0; // Track the z-index order

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Z-Index Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // Change the z-index order on button click
                setState(() {
                  stackIndex = 1;
                });
              },
              child: Text('Toggle Z-Index'),
            ),
            IndexedStack(
              index: stackIndex,
              children: <Widget>[
                Container(
                  child: ElevatedButton(
                    onPressed: (){
                      print("kop");
                    },
                    child: Text("kop"),
                  ),
                  // This widget is at the back.
                  color: Colors.transparent,
                  width: 200,
                  height: 200,
                ),
                Container(
                  child: ElevatedButton(
                    onPressed: (){
                      print("zop");
                    },
                    child: Text("zop"),
                  ),
                  // This widget is in front.
                  color: Colors.red,
                  width: 200,
                  height: 200,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
