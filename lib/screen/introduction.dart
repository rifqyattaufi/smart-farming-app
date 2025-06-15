import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/theme.dart';

class Introduction extends StatefulWidget {
  const Introduction({super.key});

  @override
  State<Introduction> createState() => _IntroductionState();
}

class _IntroductionState extends State<Introduction> {
  int _currentPage = 0;
  late PageController _pageController;
  Timer? _timer;

  final List<String> images = [
    'assets/images/onboarding1.svg',
    'assets/images/onboarding2.svg',
    'assets/images/onboarding3.svg',
  ];

  final List<String> texts = [
    'Kelola pertanian dan peternakanmu\nlebih cerdas dan efisien dalam\nsatu genggaman.',
    'Pantau, lapor, dan tingkatkan hasil panen serta kesehatan ternakmu lewat FarmCenter.',
    'Mari bersama dukung\nPertanian Berkelanjutan',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    _timer = Timer.periodic(const Duration(seconds: 10), (Timer timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          images[index],
                          height: 300,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          texts[index],
                          textAlign: TextAlign.center,
                          style: medium18.copyWith(color: dark1),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (dotIndex) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentPage == dotIndex ? green1 : grey,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: CustomButton(
              buttonText: _currentPage == 2 ? 'Masuk' : 'Selanjutnya',
              onPressed: () {
                if (_currentPage < 2) {
                  _currentPage++;
                  _pageController.animateToPage(
                    _currentPage,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  context.push('/login');
                }
              },
              backgroundColor: green1,
              textStyle: semibold16,
              textColor: white,
              key: const Key('introduction_next_button'),
            ),
          ),
        ),
      ),
    );
  }
}
