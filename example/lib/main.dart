import 'package:dot_curved_bottom_nav/dot_curved_bottom_nav.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Curved Dotted Bottom Nav',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Taped On Index $_currentPage',
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        items: const [
          Icon(Icons.dangerous),
          Icon(Icons.dangerous),
          Icon(Icons.dangerous),
          Icon(Icons.dangerous),
        ],
        scrollController: ScrollController(),
      ),
    );
  }
}
