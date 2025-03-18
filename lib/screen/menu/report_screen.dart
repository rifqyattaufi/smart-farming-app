import 'package:flutter/material.dart';
import 'package:smart_farming_app/screen/detail_item_screen.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_items.dart';
// import 'package:smart_farming_app/widget/tabs.dart';
import 'package:smart_farming_app/theme.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: blue2,
        elevation: 0,
        toolbarHeight: 100,
        title: const Header(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const Tabs(),
              ListItem(
                title: 'Daftar Tanaman',
                items: const [
                  {
                    'name': 'Melon',
                    'category': 'Kebun A',
                    'icon': 'assets/icons/goclub.svg'
                  },
                  {
                    'name': 'Pakcoy',
                    'category': 'Kebun B',
                    'icon': 'assets/icons/goclub.svg'
                  }
                ],
                type: 'basic',
                onItemTap: (context, item) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailItemScreen(item: item),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
