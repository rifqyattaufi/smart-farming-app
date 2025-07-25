import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';

class CapacityObjekSelectionGrid extends StatelessWidget {
  final List<Map<String, dynamic>> objektList;
  final Set<String> selectedObjekIds;
  final Function(String) onObjekTap;
  final VoidCallback? onSelectAll;
  final VoidCallback? onDeselectAll;
  final String title;
  final String subtitle;
  final bool isLoading;

  const CapacityObjekSelectionGrid({
    super.key,
    required this.objektList,
    required this.selectedObjekIds,
    required this.onObjekTap,
    this.onSelectAll,
    this.onDeselectAll,
    this.title = 'Pilih Objek yang Dipanen',
    this.subtitle = 'Tap pada objek untuk memilih/membatalkan pilihan',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (objektList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            Text(
              title,
              style: bold18.copyWith(color: dark1),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: dark3.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: dark3.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: dark3, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tidak ada kapasitas atau objek budidaya tersedia',
                      style: medium12.copyWith(color: dark3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Count valid objects (not empty slots)
    final validObjekList = objektList
        .where((objek) => objek['id'] != null && !(objek['isEmpty'] == true))
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: bold18.copyWith(color: dark1),
              ),
              if (validObjekList.isNotEmpty &&
                  (onSelectAll != null || onDeselectAll != null))
                TextButton(
                  onPressed: selectedObjekIds.length == validObjekList.length
                      ? onDeselectAll
                      : onSelectAll,
                  child: Text(
                    selectedObjekIds.length == validObjekList.length
                        ? 'Batal Pilih Semua'
                        : 'Pilih Semua',
                    style: medium12.copyWith(color: green1),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: regular12.copyWith(color: dark2),
          ),
          const SizedBox(height: 8),
          // Show capacity info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: blue1.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: blue1.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: blue1, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Kapasitas: ${objektList.length} slot | Terisi: ${validObjekList.length} hewan | Kosong: ${objektList.length - validObjekList.length} slot',
                    style: medium12.copyWith(color: blue1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (selectedObjekIds.isNotEmpty)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: green1.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: green1.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: green1, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${selectedObjekIds.length} hewan dipilih untuk dipanen',
                      style: medium12.copyWith(color: green1),
                    ),
                  ),
                ],
              ),
            ),
          if (selectedObjekIds.isNotEmpty) const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.1,
            ),
            itemCount: objektList.length,
            itemBuilder: (context, index) {
              final objek = objektList[index];
              final objekId = objek['id']?.toString() ?? '';
              final isAvailable = objek['isAvailable'] == true;
              final isSelected = selectedObjekIds.contains(objekId);
              final isDisabled = !isAvailable || objekId.isEmpty;

              return GestureDetector(
                onTap: isDisabled ? null : () => onObjekTap(objekId),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isDisabled
                        ? dark4.withValues(alpha: 0.5)
                        : isSelected
                            ? green1.withValues(alpha: 0.1)
                            : white,
                    border: Border.all(
                      color: isDisabled
                          ? dark3.withValues(alpha: 0.5)
                          : isSelected
                              ? green1
                              : dark3,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: green1.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : [],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          isDisabled
                              ? Icons.block
                              : isSelected
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                          color: isDisabled
                              ? dark3.withValues(alpha: 0.5)
                              : isSelected
                                  ? green1
                                  : dark3,
                          size: 22,
                          key: ValueKey('${isSelected}_${isDisabled}'),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          !isAvailable
                              ? objek['namaId']?.toString() ??
                                  'Slot ${index + 1}\n(Kosong)'
                              : objek['namaId']?.toString() ??
                                  objek['name']?.toString() ??
                                  'Objek ${index + 1}',
                          style: regular10.copyWith(
                            color: isDisabled
                                ? dark3.withValues(alpha: 0.5)
                                : isSelected
                                    ? green1
                                    : dark1,
                            fontSize: 9,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
