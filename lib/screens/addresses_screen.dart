import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../consts/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/address_provider.dart';
import '../models/shipping_address.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  bool _editing = false;

  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _line1;
  late final TextEditingController _city;
  late final TextEditingController _postal;
  String _country = 'RS';

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _phone = TextEditingController();
    _line1 = TextEditingController();
    _city = TextEditingController();
    _postal = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _line1.dispose();
    _city.dispose();
    _postal.dispose();
    super.dispose();
  }

  void _fillFrom(ShippingAddress a) {
    _name.text = a.fullName;
    _phone.text = a.phone;
    _line1.text = a.line1;
    _city.text = a.city;
    _postal.text = a.postalCode;
    _country = a.countryCode.isEmpty ? 'RS' : a.countryCode;
  }

  ShippingAddress _buildAddress() {
    return ShippingAddress(
      fullName: _name.text.trim(),
      phone: _phone.text.trim(),
      line1: _line1.text.trim(),
      city: _city.text.trim(),
      postalCode: _postal.text.trim(),
      countryCode: _country.trim(),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF17171A),
        content: Text(
          msg,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final addrProv = context.watch<AddressProvider>();

    if (!auth.isLoggedIn) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          foregroundColor: Colors.white,
          title: const Text('Addresses'),
        ),
        body: const Center(
          child: Text(
            'Uloguj se da bi upravljao adresama.',
            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800),
          ),
        ),
      );
    }

    final a = addrProv.address;
    final hasAddress = a != null && a.isValid;

    // popuni kontrolere jednom kad postoji adresa i nismo u edit modu
    if (a != null && !_editing && _name.text.isEmpty) {
      _fillFrom(a);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        title: const Text('Addresses'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
          children: [
            const Text(
              'Shipping Address',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),

            if (addrProv.loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (hasAddress && !_editing)
              _AddressCard(
                address: a,
                onEdit: () {
                  setState(() {
                    _editing = true;
                    _fillFrom(a);
                  });
                },
              )
            else
              _AddressForm(
                name: _name,
                phone: _phone,
                line1: _line1,
                city: _city,
                postal: _postal,
                countryCode: _country,
                onCountryChanged: (v) => setState(() => _country = v),
              ),

            if (addrProv.error != null) ...[
              const SizedBox(height: 10),
              _ErrorBanner(
                text: addrProv.error == 'INVALID_ADDRESS'
                    ? 'Popuni sva polja adrese.'
                    : 'Greška: ${addrProv.error}',
                onClose: () => context.read<AddressProvider>().clearError(),
              ),
            ],

            const SizedBox(height: 16),

            Row(
              children: [
                if (hasAddress && _editing) ...[
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0x33FFFFFF)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        setState(() {
                          _editing = false;
                          _fillFrom(a);
                        });
                      },
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.alpinestarsRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: addrProv.loading
                          ? null
                          : () async {
                              final newAddr = _buildAddress();
                              await context.read<AddressProvider>().save(newAddr);
                              if (!mounted) return;

                              final ok = context.read<AddressProvider>().address?.isValid == true;
                              if (!ok) {
                                _toast('Popuni adresu da sačuvaš.');
                                return;
                              }

                              setState(() => _editing = false);
                              _toast('Address saved ✅');
                            },
                      child: Text(
                        addrProv.loading ? 'Saving...' : 'Save address',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
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

class _AddressCard extends StatelessWidget {
  final ShippingAddress address;
  final VoidCallback onEdit;

  const _AddressCard({required this.address, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF17171A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x22000000)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.location_on_outlined, color: Colors.white70),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.fullName,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(address.phone,
                    style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Text(address.line1,
                    style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                Text('${address.city}, ${address.postalCode}',
                    style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                Text(address.countryCode,
                    style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0x33FFFFFF)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: onEdit,
            child: const Text('Edit', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _AddressForm extends StatelessWidget {
  final TextEditingController name;
  final TextEditingController phone;
  final TextEditingController line1;
  final TextEditingController city;
  final TextEditingController postal;
  final String countryCode;
  final ValueChanged<String> onCountryChanged;

  const _AddressForm({
    required this.name,
    required this.phone,
    required this.line1,
    required this.city,
    required this.postal,
    required this.countryCode,
    required this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    Widget field(String label, TextEditingController c, {TextInputType? type}) {
      return TextField(
        controller: c,
        keyboardType: type,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF17171A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      );
    }

    return Column(
      children: [
        field('Full Name', name),
        const SizedBox(height: 12),
        field('Phone', phone, type: TextInputType.phone),
        const SizedBox(height: 12),
        field('Address line', line1),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: field('City', city)),
            const SizedBox(width: 12),
            Expanded(child: field('Postal code', postal, type: TextInputType.number)),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: TextEditingController(text: countryCode),
          readOnly: true,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            labelText: 'Country code',
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: const Color(0xFF17171A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            suffixIcon: PopupMenuButton<String>(
              icon: const Icon(Icons.expand_more, color: Colors.white70),
              onSelected: onCountryChanged,
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'RS', child: Text('RS')),
                PopupMenuItem(value: 'US', child: Text('US')),
                PopupMenuItem(value: 'DE', child: Text('DE')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String text;
  final VoidCallback onClose;
  const _ErrorBanner({required this.text, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A0F12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x55FF3B30)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w800),
            ),
          ),
          InkWell(
            onTap: onClose,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close_rounded, color: Colors.white70, size: 18),
            ),
          )
        ],
      ),
    );
  }
}
