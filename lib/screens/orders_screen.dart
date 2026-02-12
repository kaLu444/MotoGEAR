import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../consts/app_colors.dart';
import '../models/order.dart';
import '../providers/auth_provider.dart';
import '../providers/orders_provider.dart';
import 'order_details_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  String _fmtDate(DateTime d) {
    
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString();
    return '$dd.$mm.$yy';
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'placed':
        return 'Placed';
      case 'paid':
        return 'Paid';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final ordersProv = context.watch<OrdersProvider>();

    if (!auth.isLoggedIn) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          foregroundColor: Colors.white,
          title: const Text('Orders'),
        ),
        body: const Center(
          child: Text(
            'Uloguj se da vidiš porudžbine.',
            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        title: const Text('Orders'),
      ),
      body: SafeArea(
        child: ordersProv.loading
            ? const Center(child: CircularProgressIndicator())
            : ordersProv.error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        ordersProv.error!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  )
                : ordersProv.orders.isEmpty
                    ? const _EmptyOrders()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
                        itemCount: ordersProv.orders.length,
                        itemBuilder: (_, i) {
                          final o = ordersProv.orders[i];
                          final first = o.items.isNotEmpty ? o.items.first : null;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _OrderCard(
                              order: o,
                              dateLabel: _fmtDate(o.createdAt),
                              statusLabel: _statusLabel(o.status),
                              imageAsset: first?.product.coverImage,
                              itemsCount: o.items.fold<int>(0, (s, x) => s + x.quantity),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => OrderDetailsScreen(order: o),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0x22FFFFFF)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: AppColors.alpinestarsRed.withOpacity(0.14),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.alpinestarsRed.withOpacity(0.35)),
              ),
              child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 14),
            const Text(
              'No orders yet',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              'When you place an order, it will show up here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, height: 1.35, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final String dateLabel;
  final String statusLabel;
  final String? imageAsset;
  final int itemsCount;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.dateLabel,
    required this.statusLabel,
    required this.imageAsset,
    required this.itemsCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = (order.status == 'placed')
        ? const Color(0xFFD6B24C)
        : (order.status == 'paid')
            ? const Color(0xFF4FA3FF)
            : (order.status == 'shipped')
                ? const Color(0xFFB089FF)
                : (order.status == 'delivered')
                    ? const Color(0xFF3FC36B)
                    : (order.status == 'cancelled')
                        ? const Color(0xFFFF5A5A)
                        : Colors.white70;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
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
                  width: 86,
                  height: 86,
                  child: imageAsset == null
                      ? Container(
                          color: const Color(0xFF101012),
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_not_supported_outlined, color: AppColors.textMuted),
                        )
                      : Image.asset(
                          imageAsset!,
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
                    Text(
                      'Order #${order.id.substring(0, order.id.length.clamp(0, 6))}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$itemsCount item(s) • $dateLabel',
                      style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: statusColor.withOpacity(0.35)),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 12),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '€${order.total.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }
}
