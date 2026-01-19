import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../consts/app_colors.dart';
import '../providers/products_provider.dart';

class FilterButtonWidget extends StatelessWidget {
  const FilterButtonWidget({super.key});

  Future<void> _openFilterSheet(BuildContext context) async {
    final prov = context.read<ProductsProvider>();

    final result = await showModalBottomSheet<_FilterResult>(
      context: context,
      backgroundColor: const Color(0xFF121214),
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        double minP = prov.minPrice;
        double maxP = prov.maxPrice;
        bool techAir = prov.techAirReady;
        bool waterproof = prov.waterproof;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 12,
                right: 12,
                top: 0,
                bottom: 12 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 6),
                  const Text(
                    'Filters',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // PRICE RANGE
                  const _SectionTitle('Price range'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _ChipBox(text: '€${minP.toStringAsFixed(0)}')),
                      const SizedBox(width: 10),
                      Expanded(child: _ChipBox(text: '€${maxP.toStringAsFixed(0)}')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  RangeSlider(
                    values: RangeValues(minP, maxP),
                    min: 0,
                    max: 800,
                    divisions: 16,
                    labels: RangeLabels(
                      '€${minP.toStringAsFixed(0)}',
                      '€${maxP.toStringAsFixed(0)}',
                    ),
                    onChanged: (v) => setModalState(() {
                      minP = v.start;
                      maxP = v.end;
                    }),
                  ),

                  const SizedBox(height: 10),

                  // TOGGLES
                  const _SectionTitle('Features'),
                  const SizedBox(height: 6),
                  SwitchListTile(
                    value: techAir,
                    activeColor: AppColors.alpinestarsRed,
                    title: const Text(
                      'Tech-Air® Ready',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    subtitle: const Text(
                      'Show only Tech-Air® compatible items',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    onChanged: (v) => setModalState(() => techAir = v),
                  ),
                  SwitchListTile(
                    value: waterproof,
                    activeColor: AppColors.alpinestarsRed,
                    title: const Text(
                      'Waterproof',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    subtitle: const Text(
                      'Show only waterproof items',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    onChanged: (v) => setModalState(() => waterproof = v),
                  ),

                  const SizedBox(height: 8),

                  // ACTIONS
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
                          onPressed: () {
                            setModalState(() {
                              minP = 0;
                              maxP = 800;
                              techAir = false;
                              waterproof = false;
                            });
                          },
                          child: const Text('Clear'),
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
                          onPressed: () => Navigator.pop(
                            context,
                            _FilterResult(
                              minPrice: minP,
                              maxPrice: maxP,
                              techAirReady: techAir,
                              waterproof: waterproof,
                            ),
                          ),
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
          },
        );
      },
    );

    if (result != null) {
      prov.setFilters(
        minPrice: result.minPrice,
        maxPrice: result.maxPrice,
        techAirReady: result.techAirReady,
        waterproof: result.waterproof,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<ProductsProvider, int>(
      selector: (_, p) => p.activeFilterCount,
      builder: (context, badgeCount, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _openFilterSheet(context),
              child: Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: AppColors.alpinestarsRed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.tune_rounded, color: Colors.white),
              ),
            ),
            if (badgeCount > 0)
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _FilterResult {
  final double minPrice;
  final double maxPrice;
  final bool techAirReady;
  final bool waterproof;

  const _FilterResult({
    required this.minPrice,
    required this.maxPrice,
    required this.techAirReady,
    required this.waterproof,
  });
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _ChipBox extends StatelessWidget {
  final String text;
  const _ChipBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
