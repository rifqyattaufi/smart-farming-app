import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';

class UnitItem extends StatelessWidget {
  final String unitName;
  final String? unitSymbol;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const UnitItem({
    super.key,
    required this.unitName,
    this.unitSymbol,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: Row(
              children: [
                Expanded(
                    child: Text(
                        '$unitName${unitSymbol != null ? ' - $unitSymbol' : ''}',
                        style: medium14.copyWith(color: dark1))),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: dark1),
                  onPressed: onDelete,
                ),
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: dark1),
                  onPressed: onEdit,
                ),
              ],
            ),
          ),
          Divider(
            color: green1,
            thickness: 0.5,
            height: 0,
          ),
        ],
      ),
    );
  }
}
