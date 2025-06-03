import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/tabs.dart';

import 'package:smart_farming_app/screen/laporan/tab_ternak/info_tab.dart';
import 'package:smart_farming_app/screen/laporan/tab_ternak/panen_tab.dart';
import 'package:smart_farming_app/screen/laporan/tab_ternak/harian_tab.dart';
import 'package:smart_farming_app/screen/laporan/tab_ternak/sakit_tab.dart';
import 'package:smart_farming_app/screen/laporan/tab_ternak/mati_tab.dart';
import 'package:smart_farming_app/screen/laporan/tab_ternak/vitamin_tab.dart';

class StatistikTernakReport extends StatefulWidget {
  const StatistikTernakReport({super.key});

  @override
  State<StatistikTernakReport> createState() => _StatistikTernakReportState();
}

class _StatistikTernakReportState extends State<StatistikTernakReport> {
  int _selectedTabIndex = 0;
  final List<String> tabList = [
    'Informasi',
    'Panen',
    'Harian',
    'Sakit',
    'Mati',
    'Nutrisi',
  ];
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

  final DateTime firstDate = DateTime(2025, 1, 1);
  final DateTime lastDate = DateTime(2025, 1, 31);

  final List<double> data = [10, 15, 30, 25, 20, 35, 40, 50, 45];

  final DateTime firstDates = DateTime(2025, 1, 1);
  final DateTime lastDates = DateTime(2025, 1, 31);

  final List<double> datas = [10, 15, 30, 25, 20, 35, 40, 50, 45];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: white,
          leadingWidth: 0,
          elevation: 0,
          titleSpacing: 0,
          toolbarHeight: 80,
          title: const Header(
              headerType: HeaderType.back,
              title: 'Laporan Peternakan',
              greeting: 'Laporan Ternak Ayam'),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Tabs(
              onTabChanged: _onTabChanged,
              selectedIndex: _selectedTabIndex,
              tabTitles: tabList,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                },
                children: [
                  const InfoTab(),
                  PanenTab(
                      firstDate: firstDate, lastDate: lastDate, data: data),
                  HarianTab(
                      firstDates: firstDates,
                      lastDates: lastDates,
                      datas: datas),
                  SakitTab(
                      firstDate: firstDate, lastDate: lastDate, data: data),
                  MatiTab(firstDate: firstDate, lastDate: lastDate, data: data),
                  VitaminTab(
                      firstDate: firstDate, lastDate: lastDate, data: data),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
