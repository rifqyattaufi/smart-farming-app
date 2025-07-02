import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/theme.dart';

class MainScreenPetugas extends StatelessWidget {
  final Widget child;
  const MainScreenPetugas({super.key, required this.child});

  static final tabs = [
    {
      'icon': 'home.png',
      'iconActive': 'home-filled.png',
      'label': 'Beranda',
      'location': '/home-petugas'
    },
    {
      'icon': 'box.png',
      'iconActive': 'box-filled.png',
      'label': 'Inventaris',
      'location': '/inventory-petugas'
    },
    {
      'icon': 'person.png',
      'iconActive': 'person-filled.png',
      'label': 'Akun',
      'location': '/account-petugas'
    },
  ];

  int _locationToIndex(String location) {
    final index =
        tabs.indexWhere((tab) => location.startsWith(tab['location']!));
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark),
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
              // Use active icon when selected, regular icon when not
              // Add null safety checks
              final String iconName = isActive
                  ? (tab['iconActive'] ?? tab['icon'] ?? 'home.png')
                  : (tab['icon'] ?? 'home.png');
              final String iconPath = "assets/icons/set/$iconName";
              final bool isSvg = iconPath.toLowerCase().endsWith('.svg');

              return GestureDetector(
                onTap: () => context.go(tab['location'] ?? '/home-petugas'),
                key: Key(
                    'bottom_nav_${(tab['label'] ?? 'unknown').toLowerCase()}'),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSvg)
                      SvgPicture.asset(
                        iconPath,
                        height: 28,
                        colorFilter: ColorFilter.mode(
                            isActive ? green1 : dark1, BlendMode.srcIn),
                      )
                    else
                      Image.asset(
                        iconPath,
                        height: 28,
                        color: isActive ? green1 : dark1,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      tab['label'] ?? 'Menu',
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
