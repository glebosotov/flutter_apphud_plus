import 'package:apphud_plus/apphud_plus.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

final navigationKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: navigationKey,
        theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent)),
        home: const Home());
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _apphudPlusPlugin = ApphudPlus();
  void _showSnackBarWithText(String text) {
    ScaffoldMessenger.of(navigationKey.currentContext!)
        .showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> paywallsDidLoad() async {
    final payloadsDidLoad = await _apphudPlusPlugin.paywallsDidLoad();
    _showSnackBarWithText('Paywalls did load: $payloadsDidLoad');
  }

  Future<void> checkProductByID(String id) async {
    final result = await _apphudPlusPlugin.hasProductWithId(id);
    _showSnackBarWithText('checkProductByID ($id): $result');
  }

  Future<void> buyProductByID(String id) async {
    final result = await _apphudPlusPlugin.purchase(id);
    _showSnackBarWithText('buyProductByID ($id): $result');
  }

  void _showDialogWithTextField(
      Function(String) callback, BuildContext context) {
    final controller = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Enter product ID'),
            actions: [
              ElevatedButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  callback(controller.text);
                },
              ),
            ],
            content: TextField(
              autocorrect: false,
              textCapitalization: TextCapitalization.none,
              onChanged: (value) {},
              controller: controller,
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('apphud_plus'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: paywallsDidLoad,
              child: const Text('Paywalls did load'),
            ),
            ElevatedButton(
                onPressed: () {
                  _showDialogWithTextField(
                      (p0) => checkProductByID(p0), context);
                },
                child: const Text('Check product by ID')),
            ElevatedButton(
                onPressed: () {
                  _showDialogWithTextField((p0) => buyProductByID(p0), context);
                },
                child: const Text('Buy product by ID'))
          ],
        ),
      ),
    );
  }
}
