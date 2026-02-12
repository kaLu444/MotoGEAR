// lib/widgets/filter_button_widget.dart
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
        // ✅ slider range (uzima se iz providera, ne hardkod 800)
        const sliderMin = 0.0;
        final sliderMaxRaw = prov.defaultMaxPrice;
        final sliderMax = (sliderMaxRaw <= sliderMin) ? 100.0 : sliderMaxRaw;

        // ✅ inicijalno clamp + swap ako treba
        double minP = prov.minPrice.clamp(sliderMin, sliderMax);
        double maxP = prov.maxPrice.clamp(sliderMin, sliderMax);
        if (minP > maxP) {
          final t = minP;
          minP = maxP;
          maxP = t;
        }

        bool techAir = prov.techAirReady;
        bool waterproof = prov.waterproof;

        int _divisions100(double max) {
          // korak 100 → divisions = max/100 (min 1)
          final d = (max / 100).round();
          return d.clamp(1, 500);
        }

        double _snap100(double v) => (v / 100).round() * 100.0;

        return StatefulBuilder(
          builder: (context, setModalState) {
            // ✅ snap na 100 + clamp (da UI bude stabilan)
            minP = _snap100(minP).clamp(sliderMin, sliderMax);
            maxP = _snap100(maxP).clamp(sliderMin, sliderMax);
            if (minP > maxP) {
              final t = minP;
              minP = maxP;
              maxP = t;
            }

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

                  // Price range
                  const _SectionTitle('Price range'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _ChipBox(text: '€${minP.toStringAsFixed(0)}'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ChipBox(text: '€${maxP.toStringAsFixed(0)}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  RangeSlider(
                    values: RangeValues(minP, maxP),
                    min: sliderMin,
                    max: sliderMax,
                    divisions: _divisions100(sliderMax),
                    labels: RangeLabels(
                      '€${minP.toStringAsFixed(0)}',
                      '€${maxP.toStringAsFixed(0)}',
                    ),
                    onChanged: (v) => setModalState(() {
                      var a = v.start;
                      var b = v.end;

                      // clamp
                      a = a.clamp(sliderMin, sliderMax);
                      b = b.clamp(sliderMin, sliderMax);

                      // snap na 100
                      a = _snap100(a);
                      b = _snap100(b);

                      // clamp posle snapa (za svaki slučaj)
                      a = a.clamp(sliderMin, sliderMax);
                      b = b.clamp(sliderMin, sliderMax);

                      // swap ako treba
                      if (a > b) {
                        final t = a;
                        a = b;
                        b = t;
                      }

                      minP = a;
                      maxP = b;
                    }),
                  ),

                  const SizedBox(height: 10),

                  // Features
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

                  // Actions
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
                              minP = sliderMin;
                              maxP = sliderMax;
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
