import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/search_field.dart';
import 'package:smart_farming_app/widget/unit_item.dart';

class SatuanScreen extends StatefulWidget {
  const SatuanScreen({super.key});

  @override
  State<SatuanScreen> createState() => _SatuanScreenState();
}

class _SatuanScreenState extends State<SatuanScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: white,
        scrolledUnderElevation: 0,
        toolbarHeight: 80,
        title: const Header(
            headerType: HeaderType.menu,
            title: 'Pengaturan Lainnya',
            greeting: 'Manajemen Satuan'),
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () {
            context.push('/tambah-satuan');
          },
          backgroundColor: green1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Icon(Icons.add, size: 30, color: Colors.white),
        ),
      ),
      body: ListView(
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
                const SizedBox(height: 12),
                Text('Daftar Satuan', style: bold18.copyWith(color: dark1)),
                const SizedBox(height: 12),
                UnitItem(
                  unitName: 'Kilogram',
                  unitSymbol: 'Kg',
                  onEdit: () {
                    // handle edit Kg
                  },
                  onDelete: () {
                    // handle delete Kg
                  },
                ),
                UnitItem(
                  unitName: 'Gram',
                  unitSymbol: 'g',
                  onEdit: () {
                    // handle edit g
                  },
                  onDelete: () {
                    // handle delete g
                  },
                ),
                UnitItem(
                  unitName: 'Mililiter',
                  unitSymbol: 'ml',
                  onEdit: () {
                    // handle edit ml
                  },
                  onDelete: () {
                    // handle delete ml
                  },
                ),
                UnitItem(
                  unitName: 'Buah',
                  unitSymbol: 'buah',
                  onEdit: () {
                    // handle edit buah
                  },
                  onDelete: () {
                    // handle delete buah
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
