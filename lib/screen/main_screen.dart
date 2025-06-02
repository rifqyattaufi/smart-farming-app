import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/theme.dart';

class MainScreen extends StatelessWidget {
  final Widget child;
  const MainScreen({super.key, required this.child});

  static final tabs = [
    {'icon': 'home-filled.png', 'label': 'Beranda', 'location': '/home'},
    {'icon': 'report-filled.png', 'label': 'Laporan', 'location': '/report'},
    {'icon': 'box-filled.png', 'label': 'Inventaris', 'location': '/inventory'},
    {'icon': 'person-filled.png', 'label': 'Akun', 'location': '/account'},
  ];

  int _locationToIndex(String location) {
    final index =
        tabs.indexWhere((tab) => location.startsWith(tab['location']!));
    return index == -1 ? 0 : index;
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
            color: isDarkMode ? Colors.black : Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(tabs.length, (index) {
              final tab = tabs[index];
              final isActive = index == selectedIndex;
              final String iconPath = "assets/icons/set/${tab['icon']!}";
              final bool isSvg = iconPath.toLowerCase().endsWith('.svg');

              return GestureDetector(
                onTap: () => context.go(tab['location']!),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSvg)
                      SvgPicture.asset(
                        iconPath,
                        height: 28,
                        colorFilter: ColorFilter.mode(
                            isActive ? green1 : (isDarkMode ? green1 : dark1),
                            BlendMode.srcIn),
                      )
                    else
                      Image.asset(
                        iconPath,
                        height: 28,
                        color:
                            isActive ? green1 : (isDarkMode ? green1 : dark1),
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
