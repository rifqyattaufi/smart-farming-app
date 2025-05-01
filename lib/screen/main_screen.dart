import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/theme.dart';

class MainScreen extends StatelessWidget {
  final Widget child;
  const MainScreen({super.key, required this.child});

  static final tabs = [
    {'icon': 'other.svg', 'label': 'Beranda', 'location': '/home'},
    {'icon': 'explore.svg', 'label': 'Laporan', 'location': '/report'},
    {'icon': 'gosend.svg', 'label': 'Inventaris', 'location': '/inventory'},
    {'icon': 'goclub.svg', 'label': 'Akun', 'location': '/account'},
  ];

  int _locationToIndex(String location) {
    return tabs.indexWhere((tab) => location == tab['location']);
  }

  @override
  Widget build(BuildContext context) {
    final Brightness systemBrightness =
        MediaQuery.of(context).platformBrightness;

    final bool isDarkMode = systemBrightness == Brightness.dark;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          systemNavigationBarColor: isDarkMode ? Colors.black : Colors.white,
          systemNavigationBarIconBrightness:
              isDarkMode ? Brightness.light : Brightness.dark,
        ),
      );
    });
    final String location = GoRouterState.of(context).uri.toString();
    final int selectedIndex = _locationToIndex(location);

    return Scaffold(
      body: SafeArea(
        child: child,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4D4D4).withValues(alpha: 1.2),
                spreadRadius: 0,
                blurRadius: 25,
                offset: const Offset(0, -8),
              ),
            ],
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(tabs.length, (index) {
              final tab = tabs[index];
              final isActive = index == selectedIndex;

              return GestureDetector(
                onTap: () => context.go(tab['location']!),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      "assets/icons/${tab['icon']}",
                      height: 28,
                      colorFilter: ColorFilter.mode(
                        isActive ? green1 : dark1,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tab['label']!,
                      style: (isActive ? medium12 : regular12).copyWith(
                        color: isActive ? green1 : dark1,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
