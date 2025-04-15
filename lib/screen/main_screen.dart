import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/screen/menu/home_screen.dart';
import 'package:smart_farming_app/screen/menu/report_screen.dart';
import 'package:smart_farming_app/screen/menu/inventory_screen.dart';
import 'package:smart_farming_app/screen/menu/account_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const ReportScreen(),
    const InventoryScreen(),
    const AccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4D4D4).withValues(alpha: 0.12),
              spreadRadius: 0,
              blurRadius: 25,
              offset: const Offset(0, -8),
            ),
          ],
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _bottomNavItem(icon: "other.svg", label: "Beranda", index: 0),
            _bottomNavItem(icon: "explore.svg", label: "Laporan", index: 1),
            _bottomNavItem(icon: "gosend.svg", label: "Inventaris", index: 2),
            _bottomNavItem(icon: "goclub.svg", label: "Akun", index: 3),
          ],
        ),
      ),
    );
  }

  Widget _bottomNavItem(
      {required String icon, required String label, required int index}) {
    bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            "assets/icons/$icon",
            height: 28,
            colorFilter: ColorFilter.mode(
              isActive ? green1 : dark1,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: (isActive ? medium12 : regular12).copyWith(
              color: isActive ? green1 : dark1,
            ),
          ),
        ],
      ),
    );
  }
}
