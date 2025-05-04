import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';

class DetailUserScreen extends StatefulWidget {
  const DetailUserScreen({super.key});

  @override
  State<DetailUserScreen> createState() => _DetailUserScreenState();
}

class _DetailUserScreenState extends State<DetailUserScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: white,
          leadingWidth: 0,
          titleSpacing: 0,
          elevation: 0,
          toolbarHeight: 80,
          title: const Header(
            headerType: HeaderType.back,
            title: 'Manajemen Pengguna',
            greeting: 'Detail Pengguna',
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: null,
                            child: null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      infoItem("Nama pengguna", "Adi Santoso"),
                      infoItem("Nama role", "Petugas Pelaporan"),
                      infoItem("Email pengguna", "adiSantoso@mail.com"),
                      infoItem("Nomor telepon", "0811 1111 1111"),
                      infoItem(
                          "Tanggal didaftarkan",
                          DateFormat('EEEE, dd MMMM yyyy')
                              .format(DateTime.now())),
                      infoItem("Waktu didaftarkan",
                          DateFormat('HH:mm').format(DateTime.now())),
                    ],
                  ),
                ),
                const SizedBox(height: 240),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          label: Text(
                            'Deaktivasi Pengguna',
                            style: semibold16.copyWith(color: red),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        onPressed: () {},
                        buttonText: 'Ubah Data',
                        backgroundColor: yellow2,
                        textStyle: semibold16,
                        textColor: white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: medium14.copyWith(color: dark1)),
          Text(value, style: regular14.copyWith(color: dark2)),
        ],
      ),
    );
  }
}
