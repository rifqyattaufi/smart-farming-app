import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Penanggung Jawab RFC',
                style: regular14.copyWith(color: white),
              ),
              const SizedBox(height: 4),
              Text(
                'Halo, Pak Dwi 👋',
                style: bold20.copyWith(color: white),
              ),
              const SizedBox(height: 12),
              Text(
                DateFormat('EEEE, dd MMMM yyyy HH:mm').format(DateTime.now()),
                style: regular14.copyWith(color: white),
              )
            ],
          ),
          Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white38,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/bell.svg',
                      color: white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
