import 'package:flutter/material.dart';
import 'package:motogear/screens/product_details_screen.dart';
import 'package:provider/provider.dart';

import '../consts/app_colors.dart';
import '../providers/cart_provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/cart_item_widget.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: cart.loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(12, 18, 12, 18),
                children: [
                  const Text(
                    'Cart',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (cart.error != null)
                    Text(
                      cart.error!,
                      style: const TextStyle(color: Colors.redAccent),
                    )
                  else if (cart.items.isEmpty)
                    _EmptyCart(
                      onGoShopping: () {
                        
                        context.read<NavigationProvider>().setIndex(1);
                      },
                    )
                  else ...[
                    ...cart.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CartItemWidget(
                          imageAsset: item.product.coverImage,
                          title: item.product.title,
                          subtitle:
                              item.product.subtitle, 
                          size: item.size,
                          priceLabel: item.product.priceLabel,
                          inStock: item.inStock,
                          quantity: item.quantity,
                          onMinus: () =>
                              context.read<CartProvider>().decrement(item.id),
                          onPlus: () =>
                              context.read<CartProvider>().increment(item.id),
                          onEdit: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ProductDetailsScreen(
                                  product: item.product,
                                  editingCartItemId: item.id,
                                  initialSize: item.size,
                                ),
                              ),
                            );
                          },
                          onRemove: () =>
                              context.read<CartProvider>().remove(item.id),
                        ),
                      );
                    }),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(color: Colors.white70, fontSize: 18),
                        ),
                        Text(
                          '€${cart.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.alpinestarsRed,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text(
                          'Checkout',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  final VoidCallback onGoShopping;
  const _EmptyCart({required this.onGoShopping});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x22FFFFFF)),
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: AppColors.alpinestarsRed.withOpacity(0.14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.alpinestarsRed.withOpacity(0.35),
              ),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add items from Categories and they will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 46,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.alpinestarsRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: onGoShopping,
              child: const Text(
                'Go shopping',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
