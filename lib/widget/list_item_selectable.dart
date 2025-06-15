import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:smart_farming_app/widget/image_builder.dart';

enum ListItemType { basic, simple }

class ListItemSelectable extends StatefulWidget {
  final String? title;
  final List<Map<String, dynamic>> items;
  final ListItemType type;
  final void Function(BuildContext context, Map<String, dynamic>)? onItemTap;
  final void Function(List<Map<String, dynamic>> selectedItems)?
      onSelectionChanged;

  const ListItemSelectable({
    super.key,
    this.title,
    required this.items,
    this.type = ListItemType.basic,
    this.onItemTap,
    this.onSelectionChanged,
  });

  @override
  State<ListItemSelectable> createState() => _ListItemSelectableState();
}

class _ListItemSelectableState extends State<ListItemSelectable> {
  bool isBatchMode = false;
  Set<int> selectedIndexes = {};

  void _toggleBatchMode(bool enable) {
    setState(() {
      isBatchMode = enable;
      if (!enable) selectedIndexes.clear();
    });
    _notifySelectionChanged();
  }

  void _handleTap(int index) {
    setState(() {
      if (isBatchMode) {
        if (selectedIndexes.contains(index)) {
          selectedIndexes.remove(index);
        } else {
          selectedIndexes.add(index);
        }
      } else {
        selectedIndexes = {index};
      }
    });
    _notifySelectionChanged();
  }

  void _notifySelectionChanged() {
    if (widget.onSelectionChanged != null) {
      final selectedItems =
          selectedIndexes.map((index) => widget.items[index]).toList();
      widget.onSelectionChanged!(selectedItems);
    }
  }

  void _handleLongPress(int index) {
    if (widget.type == ListItemType.basic) {
      _toggleBatchMode(true);
      _handleTap(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title!, style: bold18.copyWith(color: dark1)),
              ],
            ),
          if (widget.type == ListItemType.basic) const SizedBox(height: 8),
          if (widget.type == ListItemType.basic)
            Column(
              children: [
                Text(
                  key: const Key('batch_mode_instruction'),
                  "Tekan dan tahan untuk mengaktifkan mode pelaporan batch.",
                  style: medium12.copyWith(color: green1),
                ),
                if (isBatchMode)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                            key: const Key('select_all_checkbox'),
                            value:
                                selectedIndexes.length == widget.items.length,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  selectedIndexes = Set.from(List.generate(
                                      widget.items.length, (i) => i));
                                } else {
                                  selectedIndexes.clear();
                                }
                              });
                              _notifySelectionChanged();
                            },
                            activeColor: green1,
                            side: BorderSide(color: green1),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                          Text("Pilih semua",
                              key: const Key('select_all_text'),
                              style: medium12.copyWith(color: dark2)),
                        ],
                      ),
                      GestureDetector(
                        key: const Key('close_batch_mode_button'),
                        onTap: () => _toggleBatchMode(false),
                        child: Icon(Icons.close, size: 20, color: red),
                      )
                    ],
                  )
              ],
            ),
          if (!isBatchMode) const SizedBox(height: 10),
          ...widget.items.asMap().entries.map((entry) {
            int index = entry.key;
            var item = entry.value;
            bool isSelected = selectedIndexes.contains(index);

            Widget cardContent = _buildItemContent(item, isSelected);
            Widget child = isSelected
                ? DottedBorder(
                    color: green1,
                    strokeWidth: 2,
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(18),
                    dashPattern: const [6, 4],
                    child: cardContent,
                  )
                : cardContent;

            return GestureDetector(
              key: Key('list_item_${item['name'] ?? index}'),
              onTap: () {
                if (widget.onItemTap != null) {
                  widget.onItemTap!(context, item);
                }
                _handleTap(index);
              },
              onLongPress: widget.type == ListItemType.basic
                  ? () => _handleLongPress(index)
                  : null,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: child,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildItemContent(Map<String, dynamic> item, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 60,
              height: 60,
              child: ImageBuilder(url: item['icon'], fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'] ?? '',
                    style: semibold14.copyWith(color: dark1)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    item['category'] ?? '',
                    style: regular12.copyWith(color: green2),
                  ),
                ),
              ],
            ),
          ),
          if (widget.type == ListItemType.basic && isBatchMode)
            Checkbox(
              key: Key(
                  'checkbox_${item['name'] ?? item['id'] ?? widget.items.indexOf(item)}'),
              value: selectedIndexes.contains(widget.items.indexOf(item)),
              onChanged: (_) => _handleTap(widget.items.indexOf(item)),
              activeColor: green1,
              side: BorderSide(color: green1),
            ),
        ],
      ),
    );
  }
}
