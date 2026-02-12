// lib/screens/order_details_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../consts/app_colors.dart';
import '../models/order.dart';
import '../providers/orders_provider.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Order order;
  const OrderDetailsScreen({super.key, required this.order});

  String _fmtDateTime(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString();
    final hh = d.hour.toString().padLeft(2, '0');
    final mi = d.minute.toString().padLeft(2, '0');
    return '$dd.$mm.$yy  $hh:$mi';
  }

  bool _canCancel(String s) => s == 'placed' || s == 'paid';

  @override
  Widget build(BuildContext context) {
    final ship = order.shipping;

    final ordersProv = context.watch<OrdersProvider>();
    final cancelling = ordersProv.isCancelling(order.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        title: const Text('Order details'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
          children: [
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.id}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _fmtDateTime(order.createdAt),
                    style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800)),
                      Text(
                        '€${order.total.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                      ),
                    ],
                  ),

                  if (_canCancel(order.status)) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: cancelling
                            ? null
                            : () async {
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Cancel order?'),
                                    content: const Text('This action can’t be undone.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('No'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Yes, cancel'),
                                      ),
                                    ],
                                  ),
                                );

                                if (ok != true) return;

                                await context.read<OrdersProvider>().cancelOrder(order.id);

                                final err = context.read<OrdersProvider>().error;
                                if (err != null) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(err)),
                                  );
                                } else {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Order cancelled.')),
                                  );
                                  Navigator.pop(context);
                                }
                              },
                        icon: cancelling
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.cancel_outlined),
                        label: Text(cancelling ? 'Cancelling...' : 'Cancel order'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB3261E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            _SectionTitle('Items'),
            const SizedBox(height: 8),
            ...order.items.map((it) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ItemRow(
                  imageAsset: it.product.coverImage,
                  title: it.product.title,
                  subtitle: '${it.product.subtitle} • Size ${it.size}',
                  qty: it.quantity,
                  lineTotal: it.lineTotal,
                ),
              );
            }),

            const SizedBox(height: 12),
            _SectionTitle('Shipping address'),
            const SizedBox(height: 8),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ship.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text(ship.phone, style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Text(ship.line1, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                  Text('${ship.city}, ${ship.postalCode}',
                      style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                  Text(ship.countryCode,
                      style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- ostalo isto ---
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF17171A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x22000000)),
      ),
      child: child,
    );
  }
}

class _ItemRow extends StatelessWidget {
  final String imageAsset;
  final String title;
  final String subtitle;
  final int qty;
  final double lineTotal;

  const _ItemRow({
    required this.imageAsset,
    required this.title,
    required this.subtitle,
    required this.qty,
    required this.lineTotal,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 92,
        padding: const EdgeInsets.all(10),
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
                width: 72,
                height: 72,
                child: Image.asset(
                  imageAsset,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF101012),
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported_outlined, color: AppColors.textMuted),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text('Qty: $qty',
                      style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '€${lineTotal.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}
