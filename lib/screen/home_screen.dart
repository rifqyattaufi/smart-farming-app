import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_farming_app/screen/detail_screen.dart';
import 'package:smart_farming_app/widget/dashboard_grid.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/widget/menus.dart';
import 'package:smart_farming_app/widget/newest.dart';
import 'package:smart_farming_app/widget/tabs.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: blue2,
        elevation: 0,
        toolbarHeight: 100,
        title: const Header(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Tabs(),
              DashboardGrid(
                title: 'Statistik Tanaman',
                items: [
                  DashboardItem(title: '°C Suhu', value: '28', icon: 'other'),
                  DashboardItem(
                      title: 'Total Tanaman', value: '65', icon: 'other'),
                  DashboardItem(
                      title: 'Tanaman Mati', value: '6.5', icon: 'other'),
                  DashboardItem(
                      title: 'Kg Hasil Panen', value: '120', icon: 'other'),
                ],
              ),
              MenuGrid(
                title: 'Menu Aplikasi',
                menuItems: [
                  MenuItem(
                    title: 'Laporan',
                    icon: 'gosend',
                    backgroundColor: Colors.blue,
                    iconColor: Colors.white,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DetailScreen()),
                      );
                    },
                  ),
                  MenuItem(
                    title: 'LaporanA',
                    icon: 'gosend',
                    backgroundColor: Colors.green,
                    iconColor: Colors.white,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DetailScreen()),
                      );
                    },
                  ),
                  MenuItem(
                    title: 'LaporanB',
                    icon: 'gosend',
                    backgroundColor: Colors.red,
                    iconColor: Colors.white,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DetailScreen()),
                      );
                    },
                  ),
                  MenuItem(
                    title: 'LaporanC',
                    icon: 'gosend',
                    backgroundColor: Colors.amber,
                    iconColor: Colors.white,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DetailScreen()),
                      );
                    },
                  ),
                  MenuItem(
                    title: 'LaporanD',
                    icon: 'gosend',
                    backgroundColor: Colors.pink,
                    iconColor: Colors.white,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DetailScreen()),
                      );
                    },
                  ),
                  MenuItem(
                    title: 'LaporanE',
                    icon: 'gosend',
                    backgroundColor: Colors.purple,
                    iconColor: Colors.white,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DetailScreen()),
                      );
                    },
                  ),
                  MenuItem(
                    title: 'LaporanF',
                    icon: 'gosend',
                    backgroundColor: Colors.cyanAccent,
                    iconColor: Colors.white,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DetailScreen()),
                      );
                    },
                  ),
                  MenuItem(
                    title: 'Lainnya',
                    icon: 'other',
                    backgroundColor: Colors.lime,
                    iconColor: Colors.white,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DetailScreen()),
                      );
                    },
                  ),
                ],
              ),
              NewestReports(
                title: 'Laporan Terbaru',
                reports: const [
                  {
                    'text': 'Pak Adi telah melaporkan kondisi tanaman',
                    'icon': 'assets/icons/goclub.svg'
                  },
                  {
                    'text': 'Pak Adi telah melaporkan tanaman sakit',
                    'icon': 'assets/icons/goclub.svg'
                  },
                ],
                onViewAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DetailScreen()),
                  );
                },
              ),
              const ListItem(
                title: 'Daftar Tanaman',
                items: [
                  {
                    'name': 'Melon',
                    'category': 'Kebun A',
                    'icon': 'assets/icons/goclub.svg'
                  },
                  {
                    'name': 'Pakcoy',
                    'category': 'Kebun B',
                    'icon': 'assets/icons/goclub.svg'
                  }
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottomNavigationBar(),
    );
  }
}

Widget bottomNavigationBar() {
  return Container(
    height: 120,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFD4D4D4).withOpacity(0.12),
          spreadRadius: 0,
          blurRadius: 25,
          offset: const Offset(0, -8),
        ),
      ],
      color: Colors.white,
    ),
    child: Row(
      children: [
        bottomNavigationBarItem(
          icon: "other.svg",
          label: "Beranda",
          isActive: true,
        ),
        bottomNavigationBarItem(icon: "explore.svg", label: "Laporan"),
        bottomNavigationBarItem(icon: "gosend.svg", label: "Inventaris"),
        bottomNavigationBarItem(icon: "goclub.svg", label: "Akun"),
      ],
    ),
  );
}

Widget bottomNavigationBarItem({
  required String icon,
  required String label,
  bool isActive = false,
}) {
  return Flexible(
    flex: 1,
    fit: FlexFit.tight,
    child: Column(
      children: [
        SvgPicture.asset(
          "assets/icons/$icon",
          height: 36,
          colorFilter: ColorFilter.mode(
            isActive ? blue2 : dark1,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: (isActive ? medium12 : regular12).copyWith(
            color: isActive ? blue2 : dark1,
          ),
        ),
      ],
    ),
  );
}
