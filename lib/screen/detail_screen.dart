import 'package:flutter/material.dart';
import 'package:smart_farming_app/widget/tabs.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int _selectedTabIndex = 0;
  final PageController _pageController = PageController();

  void _onTabChanged(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Page")),
      body: Column(
        children: [
          Tabs(onTabChanged: _onTabChanged, selectedIndex: _selectedTabIndex),

          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              children: const [
                Center(child: Text("Content for Perkebunan")),
                Center(child: Text("Content for Peternakan")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
