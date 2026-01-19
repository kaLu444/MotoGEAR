import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../consts/app_colors.dart';
import '../providers/products_provider.dart'; // ovde ti je SortOption

class SortButtonWidget extends StatelessWidget {
  const SortButtonWidget({super.key});

  String _labelFrom(SortOption sort) {
    switch (sort) {
      case SortOption.featured:
        return 'Sort';
      case SortOption.priceLowHigh:
        return 'Sort: Price ↑';
      case SortOption.priceHighLow:
        return 'Sort: Price ↓';
      case SortOption.nameAZ:
        return 'Sort: A-Z';
      case SortOption.nameZA:
        return 'Sort: Z-A';
    }
  }

  Future<void> _openSortSheet(BuildContext context, SortOption current) async {
    final selected = await showModalBottomSheet<SortOption>(
      context: context,
      backgroundColor: const Color(0xFF121214),
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => _SortSheet(initial: current),
    );

    if (selected != null) {
      context.read<ProductsProvider>().setSort(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProductsProvider>();
    final label = _labelFrom(prov.sort);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _openSortSheet(context, prov.sort),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1E),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SortSheet extends StatefulWidget {
  final SortOption initial;
  const _SortSheet({required this.initial});

  @override
  State<_SortSheet> createState() => _SortSheetState();
}

class _SortSheetState extends State<_SortSheet> {
  late SortOption temp;

  @override
  void initState() {
    super.initState();
    temp = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    Widget optionTile(SortOption value, String label) {
      final isSelected = temp == value;
      return ListTile(
        title: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: AppColors.alpinestarsRed)
            : const Icon(Icons.circle_outlined, color: AppColors.textMuted),
        onTap: () => setState(() => temp = value),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 6),
          const Text(
            'Sort',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          optionTile(SortOption.featured, 'Featured'),
          optionTile(SortOption.priceLowHigh, 'Price: Low to High'),
          optionTile(SortOption.priceHighLow, 'Price: High to Low'),
          optionTile(SortOption.nameAZ, 'Name: A to Z'),
          optionTile(SortOption.nameZA, 'Name: Z to A'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0x33FFFFFF)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.alpinestarsRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(context, temp),
                  child: const Text(
                    'Apply',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
