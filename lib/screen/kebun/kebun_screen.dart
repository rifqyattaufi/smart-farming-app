import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/widget/search_field.dart';

class KebunScreen extends StatefulWidget {
  const KebunScreen({super.key});

  @override
  State<KebunScreen> createState() => _KebunScreenState();
}

class _KebunScreenState extends State<KebunScreen> {
  TextEditingController searchController = TextEditingController();

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
            title: 'Manajemen Kebun',
            greeting: 'Daftar Kebun',
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () {
            context.push('/tambah-kebun');
          },
          backgroundColor: green1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Icon(Icons.add, size: 30, color: Colors.white),
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
                  title: 'Daftar Kebun',
                  items: const [
                    {
                      'name': 'Kebun A',
                      'category': 'Melon',
                      'icon': 'assets/icons/goclub.svg',
                    },
                    {
                      'name': 'Kebun B',
                      'category': 'Anggur',
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
      ),
    );
  }
}
