import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../consts/app_colors.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/navigation_provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  
  final String? editingCartItemId; 
  final String? initialSize; 

  const ProductDetailsScreen({
    super.key,
    required this.product,
    this.editingCartItemId,
    this.initialSize,
  });

  bool get isEditing => editingCartItemId != null;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _pageIndex = 0;
  int _selectedSizeIndex = 3; 

  final List<String> _sizes = const ['S', 'M', 'L', 'XL', 'XXL'];

  List<String> get _bullets => const [
    'CE Tech-Air® Ready for advanced airbag system compatibility.',
    'Made from premium full-grain leather.',
    'Class-leading CE Level 2 shoulder and elbow protectors included.',
    'Perforated panels for superior airflow.',
  ];

  @override
  void initState() {
    super.initState();

    
    
    final initSize = widget.initialSize;
    if (initSize != null) {
      final idx = _sizes.indexOf(initSize);
      if (idx != -1) {
        _selectedSizeIndex = idx;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    final images = product.images.length >= 2
        ? product.images.take(2).toList()
        : product.images.isEmpty
        ? <String>[]
        : <String>[
            ...product.images,
            ...List.filled(2 - product.images.length, product.images.first),
          ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: EdgeInsets.zero,
              children: [
                _TopImageFixed(
                  images: images,
                  pageIndex: _pageIndex,
                  onDotTap: (i) => setState(() => _pageIndex = i),
                  onBack: () => Navigator.pop(context),
                  onShare: () {},
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 30,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.subtitle,
                        style: const TextStyle(
                          color: Color(0xFFD6B24C),
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 18),
                      ..._bullets.map(
                        (b) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 6),
                                child: Icon(
                                  Icons.circle,
                                  size: 6,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  b,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 15,
                                    height: 1.35,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Select Size',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(_sizes.length, (i) {
                          final selected = i == _selectedSizeIndex;
                          return _SizeChip(
                            label: _sizes[i],
                            selected: selected,
                            onTap: () => setState(() => _selectedSizeIndex = i),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _BottomBar(
                price: product.priceLabel,
                onWishlist: () {},
                onAddToCart: () {
                  final selectedSize = _sizes[_selectedSizeIndex];
                  final cartProv = context.read<CartProvider>();

                  
                  if (widget.isEditing) {
                    cartProv.updateItemSize(
                      cartItemId: widget.editingCartItemId!,
                      newSize: selectedSize,
                    );
                  } else {
                    cartProv.addToCart(product: product, size: selectedSize);
                  }

                  
                  context.read<NavigationProvider>().setIndex(2);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class _TopImageFixed extends StatelessWidget {
  final List<String> images;
  final int pageIndex;
  final ValueChanged<int> onDotTap;
  final VoidCallback onBack;
  final VoidCallback onShare;

  const _TopImageFixed({
    required this.images,
    required this.pageIndex,
    required this.onDotTap,
    required this.onBack,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 420,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (images.isNotEmpty)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: Image.asset(
                images[pageIndex.clamp(0, images.length - 1)],
                key: ValueKey(pageIndex),
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
            )
          else
            Container(
              color: const Color(0xFF17171A),
              alignment: Alignment.center,
              child: const Icon(
                Icons.image_not_supported_outlined,
                color: AppColors.textMuted,
                size: 40,
              ),
            ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x00000000),
                  Color(0x33000000),
                  Color(0xCC000000),
                ],
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 12,
            child: _TopIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: onBack,
            ),
          ),
          Positioned(
            top: 10,
            right: 12,
            child: _TopIconButton(
              icon: Icons.ios_share_rounded,
              onTap: onShare,
            ),
          ),
          if (images.length > 1)
            Positioned(
              bottom: 18,
              left: 0,
              right: 0,
              child: _Dots(
                count: images.length,
                index: pageIndex.clamp(0, images.length - 1),
                onTap: onDotTap,
              ),
            ),
        ],
      ),
    );
  }
}

class _TopIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0x55000000),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0x22FFFFFF)),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int index;
  final ValueChanged<int> onTap;

  const _Dots({required this.count, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return InkWell(
          borderRadius: BorderRadius.circular(99),
          onTap: () => onTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: active ? 10 : 8,
            height: active ? 10 : 8,
            decoration: BoxDecoration(
              color: active ? Colors.white : const Color(0x66FFFFFF),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        );
      }),
    );
  }
}

class _SizeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SizeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        width: 64,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.alpinestarsRed.withOpacity(0.55)
              : const Color(0xFF1A1A1E),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColors.alpinestarsRed
                : const Color(0x22000000),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final String price;
  final VoidCallback onWishlist;
  final VoidCallback onAddToCart;

  const _BottomBar({
    required this.price,
    required this.onWishlist,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F10),
        border: Border(top: BorderSide(color: Color(0x22000000))),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                price,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0x33FFFFFF)),
                      backgroundColor: const Color(0xFF151518),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: onWishlist,
                    icon: const Icon(Icons.favorite_border_rounded),
                    label: const Text(
                      'Add to Wishlist',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 6,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.alpinestarsRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: onAddToCart,
                    child: const Text(
                      'Add to Cart',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
