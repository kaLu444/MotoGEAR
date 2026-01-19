import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../consts/app_colors.dart';
import '../providers/products_provider.dart';
import 'product_details_screen.dart';

import '../widgets/product_widget.dart';
import '../widgets/category_chip_widget.dart';
import '../widgets/filter_button_widget.dart';
import '../widgets/sort_button_widget.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductsProvider>();
    final products = provider.products; // <-- jednom izračunaj

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: provider.loading
            ? const Center(child: CircularProgressIndicator())
            : provider.error != null
            ? Center(
                child: Text(
                  provider.error!,
                  style: const TextStyle(color: Colors.white),
                ),
              )
            : ListView(
                padding: EdgeInsets.zero,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(12, 18, 12, 10),
                    child: Text(
                      'All Products',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  Container(
                    color: const Color(0xFF0F0F10),
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    child: Row(
                      children: [
                        const SortButtonWidget(),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(provider.tabs.length, (
                                i,
                              ) {
                                final category = provider.tabs[i];
                                final selected =
                                    provider.selectedCategory == category;
                                return Padding(
                                  padding: EdgeInsets.only(
                                    right: i == provider.tabs.length - 1
                                        ? 0
                                        : 10,
                                  ),
                                  child: CategoryChipWidget(
                                    label: category,
                                    isSelected: selected,
                                    onTap: () =>
                                        provider.toggleCategory(category),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const FilterButtonWidget(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.length, // <-- koristi local listu
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                      itemBuilder: (context, index) {
                        final p = products[index]; // <-- koristi local listu
                        return ProductWidget(
                          imageAsset: p.coverImage,
                          title: p.title,
                          subtitle: p.subtitle,
                          priceLabel: p.priceLabel,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProductDetailsScreen(product: p),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
