import 'package:flutter/material.dart';
import '../consts/app_colors.dart';

class CartItemWidget extends StatelessWidget {
  final String imageAsset;
  final String title;
  final String subtitle;
  final String size;
  final String priceLabel;
  final bool inStock;
  final int quantity;

  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const CartItemWidget({
    super.key,
    required this.imageAsset,
    required this.title,
    required this.subtitle,
    required this.size,
    required this.priceLabel,
    required this.inStock,
    required this.quantity,
    required this.onMinus,
    required this.onPlus,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF17171A),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0x22000000)),
        ),
        child: Row(
          children: [
            
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 110,
                height: double.infinity,
                child: Image.asset(
                  imageAsset,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, _, _) => Container(
                    color: const Color(0xFF101012),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            
            Expanded(
              child: Stack(
                children: [
                  
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 92), 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 6),

                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),

                          Text(
                            'Size: $size',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),

                          const Spacer(),

                          Row(
                            children: [
                              _QtyButton(icon: Icons.remove, onTap: onMinus),
                              const SizedBox(width: 10),
                              Container(
                                width: 44,
                                height: 34,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F0F10),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0x22000000),
                                  ),
                                ),
                                child: Text(
                                  '$quantity',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              _QtyButton(icon: Icons.add, onTap: onPlus),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          priceLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          inStock ? 'In Stock' : 'Out of Stock',
                          style: TextStyle(
                            color: inStock
                                ? const Color(0xFF3FC36B)
                                : Colors.redAccent,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: onEdit,
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Colors.white70,
                          ),
                        ),
                        IconButton(
                          onPressed: onRemove,
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        width: 44,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.alpinestarsRed.withOpacity(0.45),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.alpinestarsRed.withOpacity(0.65)),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
