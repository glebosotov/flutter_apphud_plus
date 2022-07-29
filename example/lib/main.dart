import 'package:apphud_plus/apphud_plus.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _apphudPlusPlugin = ApphudPlus();

  @override
  void initState() {
    super.initState();
    test();
  }

  Future<void> test() async {
    print(await _apphudPlusPlugin.paywallsDidLoad());
    await Future.delayed(Duration(seconds: 5));
    await _apphudPlusPlugin.purchase('ft_demo_1w');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
