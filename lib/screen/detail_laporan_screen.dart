import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/header.dart';

class DetailLaporanScreen extends StatelessWidget {
  final String name;

  const DetailLaporanScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: white,
          leadingWidth: 0,
          titleSpacing: 0,
          elevation: 0,
          title: const Header(
            headerType: HeaderType.back,
            title: 'Menu Pelaporan',
            greeting: 'Detail Laporan',
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: bold20.copyWith(color: dark1),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE8E8E8)),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Lorem Ipsum",
                        style: regular14.copyWith(color: dark2)),
                    const SizedBox(height: 4),
                    Text("dolor sit amet",
                        style: semibold14.copyWith(color: dark1)),
                    const SizedBox(height: 16),
                    Text("Tanggal", style: regular14.copyWith(color: dark2)),
                    const SizedBox(height: 4),
                    Text(DateTime.now().toString(),
                        style: semibold14.copyWith(color: dark1)),
                    const SizedBox(height: 16),
                    Text("Lorem Ipsum",
                        style: regular14.copyWith(color: dark2)),
                    const SizedBox(height: 4),
                    Text("dolor sit", style: semibold14.copyWith(color: dark1)),
                    const SizedBox(height: 16),
                    Text("Deskripsi", style: regular14.copyWith(color: dark2)),
                    const SizedBox(height: 4),
                    Text(
                      "Lorem Ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                      style: regular14.copyWith(color: dark1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
