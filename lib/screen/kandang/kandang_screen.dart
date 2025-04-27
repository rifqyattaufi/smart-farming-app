import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/widget/search_field.dart';

class KandangScreen extends StatefulWidget {
  const KandangScreen({super.key});

  @override
  State<KandangScreen> createState() => _KandangScreenState();
}

class _KandangScreenState extends State<KandangScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 80,
        title: const Header(
          headerType: HeaderType.menu,
          title: 'Manajemen Kandang',
          greeting: 'Daftar Kandang',
        ),
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () {
            context.push('/tambah-kandang');
          },
          backgroundColor: green1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Icon(Icons.add, size: 30, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SearchField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              ListItem(
                title: 'Daftar Kandang',
                items: const [
                  {
                    'name': 'Kandang A',
                    'category': 'Ayam',
                    'icon': 'assets/icons/goclub.svg',
                  },
                  {
                    'name': 'Kandang B',
                    'category': 'Lele',
                    'icon': 'assets/icons/goclub.svg',
                  }
                ],
                type: 'basic',
                onItemTap: (context, item) {
                  final name = item['name'] ?? '';
                  context.push('/detail-laporan/$name');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
