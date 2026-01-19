import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../consts/app_colors.dart';
import '../services/assets_manager.dart';

import '../providers/navigation_provider.dart';
import '../providers/cart_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    // ✅ ovo uzima live broj iz CartProvider (menja se kad dodaješ/uklanjaš)
    final cartCount = context.watch<CartProvider>().cartCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _HeroBanner(
              primary: primary,
              logoAsset: AssetsManager.alpinestarsLogo,
              heroAsset: AssetsManager.homeHero,
              cartCount: cartCount, // ✅ FIX
              onShopNow: () {},
              onCart: () {
                context.read<NavigationProvider>().setIndex(2); // Cart tab
              },
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              color: const Color(0xFF121214),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "THE WORLD'S LEADING MOTORSPORTS PROTECTION",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 0.4,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Innovative gear for motorcycle riders, racers, drivers\nand athletes.",
                    style: TextStyle(
                      color: AppColors.textMuted,
                      height: 1.35,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              color: const Color(0xFF0F0F10),
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _QuickCategoryItem(
                    icon: Icons.shield_outlined,
                    label: 'Tech-Air',
                    isActive: true,
                  ),
                  _QuickCategoryItem(
                    icon: Icons.flag_outlined,
                    label: 'Racing',
                  ),
                  _QuickCategoryItem(
                    icon: Icons.sports_motorsports_outlined,
                    label: 'Helmets',
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: _TechAirExplainedCard(
                imageAsset: AssetsManager.techAirExplained,
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
              child: Row(
                children: [
                  Expanded(
                    child: _PromoTile(
                      titleTop: 'NEW GEAR',
                      imageAsset: AssetsManager.tileNewGear,
                      ctaText: 'DISCOVER',
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PromoTile(
                      titleTop: 'RIDING BOOTS',
                      imageAsset: AssetsManager.tileBoots,
                      ctaText: 'SHOP NOW',
                      onTap: () {},
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

class _HeroBanner extends StatelessWidget {
  final Color primary;
  final String logoAsset;
  final String heroAsset;
  final int cartCount;
  final VoidCallback onShopNow;
  final VoidCallback onCart;

  const _HeroBanner({
    required this.primary,
    required this.logoAsset,
    required this.heroAsset,
    required this.cartCount,
    required this.onShopNow,
    required this.onCart,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            heroAsset,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),

          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x88000000),
                  Color(0x33000000),
                  Color(0xCC000000),
                ],
              ),
            ),
          ),

          Positioned(
            top: -30,
            left: -20,
            right: 20,
            child: Row(
              children: [
                SizedBox(
                  height: 150,
                  child: Image.asset(
                    logoAsset,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                const Spacer(),
                _BadgeIconButton(
                  icon: Icons.shopping_cart_outlined,
                  badgeCount: cartCount,
                  onTap: onCart,
                ),
              ],
            ),
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GEAR UP\n& RIDE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    height: 0.95,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onPressed: onShopNow,
                    child: const Text(
                      'SHOP NOW',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconButtonCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButtonCircle({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0x66000000),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0x22FFFFFF)),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _BadgeIconButton extends StatelessWidget {
  final IconData icon;
  final int badgeCount;
  final VoidCallback onTap;

  const _BadgeIconButton({
    required this.icon,
    required this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _IconButtonCircle(icon: icon, onTap: onTap),
        if (badgeCount > 0)
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFF0B0B0C), width: 2),
              ),
              child: Text(
                '$badgeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _QuickCategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _QuickCategoryItem({
    required this.icon,
    required this.label,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Expanded(
      child: Column(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: isActive
                  ? primary.withOpacity(0.15)
                  : const Color(0xFF17171A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isActive
                    ? primary.withOpacity(0.55)
                    : const Color(0x22FFFFFF),
              ),
            ),
            child: Icon(icon, color: isActive ? primary : Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoTile extends StatelessWidget {
  final String titleTop;
  final String imageAsset;
  final String ctaText;
  final VoidCallback onTap;

  const _PromoTile({
    required this.titleTop,
    required this.imageAsset,
    required this.ctaText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 160,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x55000000), Color(0xAA000000)],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Text(
                  titleTop,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Positioned(
                left: 10,
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    ctaText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TechAirExplainedCard extends StatelessWidget {
  final String imageAsset;

  const _TechAirExplainedCard({required this.imageAsset});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 250,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              imageAsset,
              fit: BoxFit.cover,
              alignment: Alignment.centerLeft,
              filterQuality: FilterQuality.high,
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0x00000000),
                      Color(0x22000000),
                      Color(0xAA000000),
                    ],
                    stops: [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth * 0.55,
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tech-Air®',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Intelligent airbag protection\ntrusted by professionals.',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color(0xFFD0D0D0),
                                fontSize: 12.5,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
