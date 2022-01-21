import 'package:flutter/material.dart';

class FakePage extends StatefulWidget {
  FakePage({Key? key}) : super(key: key);

  @override
  _FakePageState createState() => _FakePageState();
}

class _FakePageState extends State<FakePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Text"),
      ),
    );
  }
}