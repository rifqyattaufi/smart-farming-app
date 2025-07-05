import 'package:flutter/material.dart';
import 'package:smart_farming_app/screen/inventaris/detail_pemakaian_inventaris_from_laporan_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/detail/detail_laporan_harian_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/detail/detail_laporan_mati_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/detail/detail_laporan_nutrisi_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/detail/detail_laporan_panen_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/detail/detail_laporan_sakit_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/detail/detail_laporan_harian_ternak_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/detail/detail_laporan_panen_ternak_screen.dart';
import 'package:smart_farming_app/utils/app_utils.dart';

void navigateToDetailLaporan(
  BuildContext context, {
  required String idLaporan,
  required String jenisLaporan,
  required String jenisBudidaya,
}) {
  Widget? targetScreen;

  switch (jenisLaporan) {
    case 'harian':
      if (jenisBudidaya == 'tumbuhan') {
        targetScreen = DetailLaporanHarianScreen(idLaporanHarian: idLaporan);
      } else if (jenisBudidaya == 'hewan') {
        targetScreen =
            DetailLaporanHarianTernakScreen(idLaporanHarianTernak: idLaporan);
      }
      break;
    case 'sakit':
      targetScreen = DetailLaporanSakitScreen(idLaporanSakit: idLaporan);
      break;
    case 'kematian':
      targetScreen = DetailLaporanMatiScreen(idLaporanMati: idLaporan);
      break;
    case 'vitamin':
      targetScreen = DetailLaporanNutrisiScreen(idLaporanNutrisi: idLaporan);
      break;
    case 'panen':
      if (jenisBudidaya == 'tumbuhan') {
        targetScreen = DetailLaporanPanenScreen(idLaporanPanen: idLaporan);
      } else if (jenisBudidaya == 'hewan') {
        targetScreen =
            DetailLaporanPanenTernakScreen(idLaporanPanenTernak: idLaporan);
      }
      break;
    // Implementasi untuk detail pemakaian inventaris dari laporan
    case 'inventaris':
      targetScreen =
          DetailPemakaianInventarisFromLaporanScreen(idLaporan: idLaporan);
      break;
  }

  if (targetScreen != null) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => targetScreen!),
    );
  } else {
    showAppToast(context, 'Tidak dapat membuka detail untuk laporan ini.');
  }
}
