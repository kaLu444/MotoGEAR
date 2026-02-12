
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../consts/app_colors.dart';
import 'admin_product_screen.dart' as admin_products;

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        title: const Text('Admin Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _AdminNavTile(
            icon: Icons.inventory_2_outlined,
            title: 'Products',
            subtitle: 'Add / edit / delete products',
            screen: admin_products.AdminProductsScreen(),
          ),
          SizedBox(height: 12),
          _AdminNavTile(
            icon: Icons.people_alt_outlined,
            title: 'Users',
            subtitle: 'User overview + admin toggle',
            screen: AdminUsersScreen(),
          ),
          SizedBox(height: 12),
          _AdminNavTile(
            icon: Icons.receipt_long_outlined,
            title: 'Orders',
            subtitle: 'Orders grouped by users',
            screen: AdminOrdersScreen(),
          ),
        ],
      ),
    );
  }
}

class _AdminNavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget screen;

  const _AdminNavTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () =>
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen)),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF17171A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x22000000)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}





class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final users = FirebaseFirestore.instance.collection('users');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        title: const Text('Admin • Users'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: users.orderBy('email').snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Text(
                'Error: ${snap.error}',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            );
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final d = docs[i];
              final data = d.data();
              final email = (data['email'] ?? d.id).toString();
              final name = (data['fullName'] ?? '').toString();
              final isAdmin = (data['isAdmin'] as bool?) ?? false;

              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF17171A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x22000000)),
                ),
                child: ListTile(
                  title: Text(
                    name.isEmpty ? email : name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  subtitle: Text(
                    email,
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                  trailing: Switch(
                    value: isAdmin,
                    onChanged: (v) async {
                      await users.doc(d.id).set({
                        'isAdmin': v,
                        'updatedAt': FieldValue.serverTimestamp(),
                      }, SetOptions(merge: true));
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}





class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usersQ = FirebaseFirestore.instance.collection('users').orderBy('email');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        title: const Text('Admin • Orders'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: usersQ.snapshots(),
        builder: (context, usersSnap) {
          if (usersSnap.hasError) {
            return Center(
              child: Text(
                'Error: ${usersSnap.error}',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            );
          }
          if (!usersSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = usersSnap.data!.docs;

          if (users.isEmpty) {
            return const Center(
              child: Text('No users.', style: TextStyle(color: Colors.white70)),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final uDoc = users[i];
              final u = uDoc.data();
              final uid = uDoc.id;
              final name = (u['fullName'] ?? '').toString().trim();
              final email = (u['email'] ?? uid).toString().trim();

              final ordersQ = FirebaseFirestore.instance
                  .collection('orders')
                  .doc(uid)
                  .collection('items')
                  .orderBy('createdAt', descending: true);

              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF17171A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x22000000)),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    collapsedIconColor: Colors.white54,
                    iconColor: Colors.white70,
                    title: Text(
                      name.isEmpty ? email : name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    subtitle: Text(
                      email,
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                    children: [
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: ordersQ.snapshots(),
                        builder: (context, ordersSnap) {
                          if (ordersSnap.hasError) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Text(
                                'Error: ${ordersSnap.error}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            );
                          }
                          if (!ordersSnap.hasData) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            );
                          }

                          final orders = ordersSnap.data!.docs;

                          if (orders.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Text(
                                'No orders for this user.',
                                style: TextStyle(color: Colors.white54),
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            itemCount: orders.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, j) {
                              final oDoc = orders[j];
                              final o = oDoc.data();
                              final status = (o['status'] ?? 'placed').toString();
                              final total = (o['total'] as num?)?.toDouble() ?? 0.0;

                              return Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF101013),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0x22000000)),
                                ),
                                child: ListTile(
                                  title: Text(
                                    'Order ${oDoc.id}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'total: €${total.toStringAsFixed(2)} • status: $status',
                                    style: const TextStyle(color: AppColors.textMuted),
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (v) async {
                                      await oDoc.reference.set({
                                        'status': v,
                                        'updatedAt': FieldValue.serverTimestamp(),
                                      }, SetOptions(merge: true));
                                    },
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(value: 'placed', child: Text('placed')),
                                      PopupMenuItem(value: 'paid', child: Text('paid')),
                                      PopupMenuItem(value: 'shipped', child: Text('shipped')),
                                      PopupMenuItem(value: 'delivered', child: Text('delivered')),
                                      PopupMenuItem(value: 'cancelled', child: Text('cancelled')),
                                    ],
                                    icon: const Icon(Icons.more_horiz, color: Colors.white70),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
