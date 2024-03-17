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
  int _currentPage = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _currentPage == 1
          ? ListView.separated(
              controller: _scrollController,
              itemBuilder: (BuildContext context, int index) {
                return const ListTile(
                  title: Text("I maybe a notification!"),
                  leading: Icon(Icons.notification_important),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(
                  height: 10,
                );
              },
              itemCount: 50,
            )
          : AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              color: [
                const Color(0xffF5F7F8),
                const Color(0xff9EC8B9),
                const Color(0xffFDE5D4),
                const Color(0xffF1D4E5)
              ][_currentPage],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Taped On Index $_currentPage',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: DotCurvedBottomNav(
        scrollController: _scrollController,

        hideOnScroll: true,
        indicatorColor: Colors.blue,
        backgroundColor: Colors.black,
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.ease,
        // margin: const EdgeInsets.all(0),
        selectedIndex: _currentPage,
        indicatorSize: 5,
        borderRadius: 25,
        height: 70,
        onTap: (index) {
          setState(() => _currentPage = index);
        },
        items: [
          Icon(
            Icons.home,
            color: _currentPage == 0 ? Colors.blue : Colors.white,
          ),
          Icon(
            Icons.notification_add,
            color: _currentPage == 1 ? Colors.blue : Colors.white,
          ),
          Icon(
            Icons.color_lens,
            color: _currentPage == 2 ? Colors.blue : Colors.white,
          ),
          Icon(
            Icons.person,
            color: _currentPage == 3 ? Colors.blue : Colors.white,
          ),
        ],
      ),
    );
  }
}
