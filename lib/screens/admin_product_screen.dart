
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../consts/app_colors.dart';
import '../models/product.dart';





class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});

  Product _fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final data = d.data() ?? {};

    
    final id = d.id;
    final category = (data['category'] ?? '').toString();
    final title = (data['title'] ?? '').toString();
    final subtitle = (data['subtitle'] ?? '').toString();
    final priceLabel = (data['priceLabel'] ?? '').toString();

    final num pv = (data['priceValue'] is num) ? data['priceValue'] as num : 0;
    final priceValue = pv.toDouble();

    final coverImage = (data['coverImage'] ?? data['imageUrl'] ?? '').toString();

    final imagesRaw = (data['images'] as List?) ?? const [];
    final images = imagesRaw.map((e) => e.toString()).toList();

    final bulletsRaw = (data['bullets'] as List?) ?? const [];
    final bullets = bulletsRaw.map((e) => e.toString()).toList();

    final sizesRaw = (data['sizes'] as List?) ?? const [];
    final sizes = sizesRaw.map((e) => e.toString()).toList();

    final techAirReady = (data['techAirReady'] as bool?) ?? false;
    final waterproof = (data['waterproof'] as bool?) ?? false;

    
    
    return Product(
      id: id,
      category: category,
      title: title,
      subtitle: subtitle,
      priceLabel: priceLabel,
      priceValue: priceValue,
      coverImage: coverImage,
      images: images,
      techAirReady: techAirReady,
      waterproof: waterproof,
      bullets: bullets,
      sizes: sizes,
    );
  }

  Future<void> _createEmptyProduct(BuildContext context) async {
    
    final ref = FirebaseFirestore.instance.collection('products').doc();

    final p = Product(
      id: ref.id,
      category: '',
      title: '',
      subtitle: '',
      priceLabel: '€0.00',
      priceValue: 0,
      coverImage: '',
      images: const [],
      techAirReady: false,
      waterproof: false,
      bullets: const [],
      sizes: const [],
    );

    
    
    

    
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EditProductScreen(product: p)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final col = FirebaseFirestore.instance.collection('products');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        title: const Text('Admin • Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _createEmptyProduct(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: col.orderBy('updatedAt', descending: true).snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return const Center(
              child: Text(
                'Loading error.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No products.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final d = docs[i];
              final p = _fromDoc(d);

              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF17171A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x22000000)),
                ),
                child: ListTile(
                  title: Text(
                    p.title.isEmpty ? '(no title)' : p.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  subtitle: Text(
                    '${p.category.isEmpty ? 'No category' : p.category} • ${p.priceLabel}',
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white70),
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EditProductScreen(product: p),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () async {
                          await col.doc(p.id).delete();
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





class EditProductScreen extends StatefulWidget {
  final Product product;
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late final TextEditingController _category;
  late final TextEditingController _title;
  late final TextEditingController _subtitle;
  late final TextEditingController _priceLabel;
  late final TextEditingController _priceValue;
  late final TextEditingController _coverImage;

  late bool _techAirReady;
  late bool _waterproof;

  late List<String> _images;
  late List<String> _bullets;
  late List<String> _sizes;

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final p = widget.product;

    _category = TextEditingController(text: p.category);
    _title = TextEditingController(text: p.title);
    _subtitle = TextEditingController(text: p.subtitle);
    _priceLabel = TextEditingController(text: p.priceLabel);
    _priceValue = TextEditingController(text: p.priceValue.toStringAsFixed(2));
    _coverImage = TextEditingController(text: p.coverImage);

    _techAirReady = p.techAirReady;
    _waterproof = p.waterproof;

    _images = List<String>.from(p.images);
    _bullets = List<String>.from(p.bullets);
    _sizes = List<String>.from(p.sizes);
  }

  @override
  void dispose() {
    _category.dispose();
    _title.dispose();
    _subtitle.dispose();
    _priceLabel.dispose();
    _priceValue.dispose();
    _coverImage.dispose();
    super.dispose();
  }

  double _parsePrice(String v) {
    final s = v.replaceAll(',', '.').trim();
    return double.tryParse(s) ?? 0.0;
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final price = _parsePrice(_priceValue.text);
      if (_title.text.trim().isEmpty) throw StateError('Title is required.');
      if (_category.text.trim().isEmpty) throw StateError('Category is required.');
      if (price <= 0) throw StateError('Price must be > 0.');

      final updated = widget.product.copyWith(
        category: _category.text.trim(),
        title: _title.text.trim(),
        subtitle: _subtitle.text.trim(),
        priceLabel: _priceLabel.text.trim(),
        priceValue: price,
        coverImage: _coverImage.text.trim(),
        images: _images,
        techAirReady: _techAirReady,
        waterproof: _waterproof,
        bullets: _bullets,
        sizes: _sizes.isEmpty ? ['S', 'M', 'L', 'XL', 'XXL'] : _sizes,
      );

      await FirebaseFirestore.instance
          .collection('products')
          .doc(updated.id)
          .set({
        ...updated.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      Navigator.pop(context, 'Saved.');
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Bad state: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _editList({
    required String title,
    required List<String> initial,
    required void Function(List<String>) onChanged,
    String hint = 'One item per line',
  }) async {
    final c = TextEditingController(text: initial.join('\n'));
    final res = await showDialog<List<String>>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF17171A),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        content: TextField(
          controller: c,
          maxLines: 10,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.white38)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final items = c.text
                  .split('\n')
                  .map((x) => x.trim())
                  .where((x) => x.isNotEmpty)
                  .toList();
              Navigator.pop(context, items);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
    if (res != null) setState(() => onChanged(res));
  }

  Widget _field(String label, TextEditingController c,
      {TextInputType? keyboard, String? hint}) {
    return TextField(
      controller: c,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF17171A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        title: const Text('Edit product'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field('Category', _category, hint: 'e.g. Shoes, Jackets, Gloves'),
          const SizedBox(height: 12),
          _field('Title', _title),
          const SizedBox(height: 12),
          _field('Subtitle / Description', _subtitle),
          const SizedBox(height: 12),
          _field('Price label', _priceLabel, hint: 'e.g. €179.95'),
          const SizedBox(height: 12),
          _field('Price value (number)', _priceValue, keyboard: TextInputType.number),
          const SizedBox(height: 12),
          _field('Cover image URL', _coverImage),
          const SizedBox(height: 12),

          SwitchListTile(
            value: _techAirReady,
            onChanged: (v) => setState(() => _techAirReady = v),
            title: const Text('Tech-Air ready', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Show Tech-Air badge', style: TextStyle(color: Colors.white54)),
          ),
          SwitchListTile(
            value: _waterproof,
            onChanged: (v) => setState(() => _waterproof = v),
            title: const Text('Waterproof', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Show Waterproof badge', style: TextStyle(color: Colors.white54)),
          ),

          const SizedBox(height: 8),
          _ListCard(
            title: 'Images',
            subtitle: '${_images.length} items',
            onTap: () => _editList(
              title: 'Edit images (URLs)',
              initial: _images,
              onChanged: (v) => _images = v,
              hint: 'One image URL per line',
            ),
          ),
          const SizedBox(height: 12),
          _ListCard(
            title: 'Bullets',
            subtitle: '${_bullets.length} items',
            onTap: () => _editList(
              title: 'Edit bullets',
              initial: _bullets,
              onChanged: (v) => _bullets = v,
            ),
          ),
          const SizedBox(height: 12),
          _ListCard(
            title: 'Sizes',
            subtitle: _sizes.isEmpty ? 'Default sizes will be used' : _sizes.join(', '),
            onTap: () => _editList(
              title: 'Edit sizes',
              initial: _sizes,
              onChanged: (v) => _sizes = v,
              hint: 'S\nM\nL\nXL\nXXL',
            ),
          ),

          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2A0F12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0x55FF3B30)),
              ),
              child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            ),
          ],

          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.alpinestarsRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _saving ? null : _save,
              child: Text(
                _saving ? 'Saving...' : 'Save',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ListCard({required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF17171A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x22000000)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontWeight: FontWeight.w700,
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
