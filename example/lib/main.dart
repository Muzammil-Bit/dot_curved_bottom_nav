import 'package:dot_curved_bottom_nav/dot_curved_bottom_nav.dart';
import 'package:flutter/material.dart';

import 'nav_style.dart';
import 'pages/home_page.dart';
import 'pages/inbox_page.dart';
import 'pages/profile_page.dart';
import 'pages/saved_page.dart';
import 'pages/style_page.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xff4F8BFF);
    return MaterialApp(
      title: 'Dot Curved Bottom Nav',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const ShowcaseScreen(),
    );
  }
}

/// The tabs in the order they appear in the bar. The Style tab sits second so
/// it stays visible when the bar is cut down to two items.
const _tabs = <({IconData icon, String label})>[
  (icon: Icons.home_rounded, label: 'Home'),
  (icon: Icons.tune_rounded, label: 'Style'),
  (icon: Icons.chat_bubble_rounded, label: 'Inbox'),
  (icon: Icons.person_rounded, label: 'Profile'),
  (icon: Icons.bookmark_rounded, label: 'Saved'),
];

class ShowcaseScreen extends StatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  State<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends State<ShowcaseScreen> {
  int _currentIndex = 0;
  NavStyle _style = const NavStyle();

  // Only one tab is built at a time, so every tab can share this controller
  // and the bar hides on scroll no matter which tab is open.
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateStyle(NavStyle style) {
    setState(() {
      _style = style;
      if (_currentIndex >= style.itemCount) _currentIndex = 1;
    });
  }

  Widget _buildPage() {
    final controller = _scrollController;
    return switch (_currentIndex) {
      0 => HomePage(
          scrollController: controller,
          onOpenStyle: () => setState(() => _currentIndex = 1),
        ),
      1 => StylePage(
          scrollController: controller,
          style: _style,
          onChanged: _updateStyle,
        ),
      2 => InboxPage(scrollController: controller),
      3 => ProfilePage(scrollController: controller),
      _ => SavedPage(scrollController: controller),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: KeyedSubtree(
        key: ValueKey(_currentIndex),
        child: _buildPage(),
      ),
      bottomNavigationBar: DotCurvedBottomNav(
        scrollController: _scrollController,
        hideOnScroll: _style.hideOnScroll,
        selectedIndex: _currentIndex,
        backgroundColor: _style.backgroundColor,
        indicatorColor: _style.indicatorColor,
        indicatorSize: _style.indicatorSize,
        borderRadius: _style.borderRadius,
        height: _style.height,
        margin: EdgeInsets.fromLTRB(
          _style.horizontalMargin,
          0,
          _style.horizontalMargin,
          20,
        ),
        animationDuration: Duration(milliseconds: _style.durationMs),
        animationCurve: _style.curve.curve,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          for (var i = 0; i < _style.itemCount; i++)
            Tooltip(
              message: _tabs[i].label,
              child: Icon(
                _tabs[i].icon,
                color: i == _currentIndex
                    ? _style.indicatorColor
                    : _style.idleIconColor,
              ),
            ),
        ],
      ),
    );
  }
}
