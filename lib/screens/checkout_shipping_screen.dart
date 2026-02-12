import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../consts/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/address_provider.dart';
import '../providers/payment_provider.dart';
import '../providers/navigation_provider.dart';

import '../models/shipping_address.dart';
import '../models/payment_card.dart';

import '../services/orders_service.dart';

class CheckoutShippingScreen extends StatefulWidget {
  const CheckoutShippingScreen({super.key});

  @override
  State<CheckoutShippingScreen> createState() => _CheckoutShippingScreenState();
}

class _CheckoutShippingScreenState extends State<CheckoutShippingScreen> {
  
  bool _editingAddress = false;

  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _line1;
  late final TextEditingController _city;
  late final TextEditingController _postal;
  String _country = 'RS';

  
  bool _editingCard = false;

  late final TextEditingController _holder;
  String _brand = 'Visa';
  late final TextEditingController _number; 
  int _expMonth = 1;
  int _expYear = 2026;

  @override
  void initState() {
    super.initState();

    _name = TextEditingController();
    _phone = TextEditingController();
    _line1 = TextEditingController();
    _city = TextEditingController();
    _postal = TextEditingController();

    _holder = TextEditingController();
    _number = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _line1.dispose();
    _city.dispose();
    _postal.dispose();

    _holder.dispose();
    _number.dispose();
    super.dispose();
  }

  
  void _fillAddressFrom(ShippingAddress a) {
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

  
  void _fillCardFrom(PaymentCard c) {
    _holder.text = c.holderName;
    _brand = c.brand.isEmpty ? 'Visa' : c.brand;
    _number.text = c.number; 
    _expMonth = c.expMonth;
    _expYear = c.expYear;
  }

  PaymentCard _buildCard() {
    return PaymentCard(
      holderName: _holder.text.trim(),
      brand: _brand.trim(),
      number: _number.text.trim(),
      expMonth: _expMonth,
      expYear: _expYear,
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
    final cart = context.watch<CartProvider>();
    final addrProv = context.watch<AddressProvider>();
    final payProv = context.watch<PaymentProvider>();

    if (!auth.isLoggedIn) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          foregroundColor: Colors.white,
          title: const Text('Checkout'),
        ),
        body: const Center(
          child: Text(
            'Uloguj se da bi završio kupovinu.',
            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800),
          ),
        ),
      );
    }

    
    final a = addrProv.address;

    if (a != null && !_editingAddress && _name.text.isEmpty) {
      _fillAddressFrom(a);
    }

    final hasAddress = a != null && a.isValid;

    
    final c = payProv.card;

    if (c != null && !_editingCard && _holder.text.isEmpty) {
      _fillCardFrom(c);
    }

    final hasCard = c != null && c.isValid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        title: const Text('Checkout'),
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
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),

            if (addrProv.loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (hasAddress && !_editingAddress)
              _AddressCard(
                address: a,
                onEdit: () {
                  setState(() {
                    _editingAddress = true;
                    _fillAddressFrom(a);
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

            if (hasAddress && _editingAddress) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0x33FFFFFF)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    setState(() {
                      _editingAddress = false;
                      _fillAddressFrom(a);
                    });
                  },
                  child: const Text('Cancel edit', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],

            const SizedBox(height: 22),

            
            const Text(
              'Credit Card',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),

            if (payProv.loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (hasCard && !_editingCard)
              _CardPreview(
                card: c,
                onEdit: () {
                  setState(() {
                    _editingCard = true;
                    _fillCardFrom(c);
                  });
                },
              )
            else
              _CardForm(
                holder: _holder,
                brand: _brand,
                number: _number,
                expMonth: _expMonth,
                expYear: _expYear,
                onBrandChanged: (v) => setState(() => _brand = v),
                onMonthChanged: (v) => setState(() => _expMonth = v),
                onYearChanged: (v) => setState(() => _expYear = v),
              ),

            if (payProv.error != null) ...[
              const SizedBox(height: 10),
              _ErrorBanner(
                text: payProv.error == 'INVALID_CARD'
                    ? 'Popuni ispravno podatke kartice.'
                    : 'Greška: ${payProv.error}',
                onClose: () => context.read<PaymentProvider>().clearError(),
              ),
            ],

            if (hasCard && _editingCard) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0x33FFFFFF)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    setState(() {
                      _editingCard = false;
                      _fillCardFrom(c);
                    });
                  },
                  child: const Text('Cancel edit', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],

            const SizedBox(height: 18),

            
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF17171A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0x22000000)),
              ),
              child: Column(
                children: [
                  _RowKV(label: 'Subtotal', value: '€${cart.total.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  const _RowKV(label: 'Shipping', value: 'FREE'),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0x22FFFFFF)),
                  const SizedBox(height: 10),
                  _RowKV(
                    label: 'Total',
                    value: '€${cart.total.toStringAsFixed(2)}',
                    strong: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            
            SizedBox(
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.alpinestarsRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: (addrProv.loading || payProv.loading)
                    ? null
                    : () async {
                        
                        if (cart.items.isEmpty) {
                          _toast('Korpa je prazna.');
                          return;
                        }

                        
                        if (!(hasAddress && !_editingAddress)) {
                          final newAddr = _buildAddress();
                          await context.read<AddressProvider>().save(newAddr);
                          if (!mounted) return;

                          final okAddr =
                              
                              context.read<AddressProvider>().address?.isValid == true;
                          if (!okAddr) {
                            _toast('Popuni adresu da nastaviš.');
                            return;
                          }
                          setState(() => _editingAddress = false);
                        }

                        
                        if (!(hasCard && !_editingCard)) {
                          final newCard = _buildCard();
                          
                          await context.read<PaymentProvider>().save(newCard);
                          if (!mounted) return;

                          
                          final okCard = context.read<PaymentProvider>().card?.isValid == true;
                          if (!okCard) {
                            _toast('Popuni karticu da nastaviš.');
                            return;
                          }
                          setState(() => _editingCard = false);
                        }

                        
                        final uid = auth.user!.id;
                        final shipping = context.read<AddressProvider>().address;

                        if (shipping == null || !shipping.isValid) {
                          _toast('Adresa nije validna.');
                          return;
                        }

                        try {
                          await OrdersService().placeOrder(
                            uid: uid,
                            items: cart.items,
                            total: cart.total,
                            shipping: shipping,
                          );

                          await context.read<CartProvider>().clear();

                          if (!mounted) return;
                          _toast('Order placed ✅');

                          Navigator.popUntil(context, (r) => r.isFirst);
                          context.read<NavigationProvider>().setIndex(3); 
                        } catch (e) {
                          _toast('Greška: $e');
                        }
                      },
                child: Text(
                  (addrProv.loading || payProv.loading) ? 'Saving...' : 'Continue',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ),
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
                Text(address.fullName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(address.phone,
                    style:
                        const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700)),
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
        InputDecorator(
          decoration: InputDecoration(
            labelText: 'Country code',
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: const Color(0xFF17171A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: countryCode,
              dropdownColor: const Color(0xFF17171A),
              icon: const Icon(Icons.expand_more, color: Colors.white70),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
              onChanged: (v) {
                if (v != null) onCountryChanged(v);
              },
              items: const [
                DropdownMenuItem(value: 'RS', child: Text('RS')),
                DropdownMenuItem(value: 'US', child: Text('US')),
                DropdownMenuItem(value: 'DE', child: Text('DE')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}



class _CardPreview extends StatelessWidget {
  final PaymentCard card;
  final VoidCallback onEdit;

  const _CardPreview({required this.card, required this.onEdit});

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
          const Icon(Icons.credit_card_rounded, color: Colors.white70),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.holderName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(
                  '${card.brand}  ${card.number}', 
                  style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Text(
                  'Exp: ${card.expMonth.toString().padLeft(2, '0')}/${card.expYear}',
                  style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w800),
                ),
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

class _CardForm extends StatelessWidget {
  final TextEditingController holder;
  final String brand;
  final TextEditingController number;
  final int expMonth;
  final int expYear;

  final ValueChanged<String> onBrandChanged;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<int> onYearChanged;

  const _CardForm({
    required this.holder,
    required this.brand,
    required this.number,
    required this.expMonth,
    required this.expYear,
    required this.onBrandChanged,
    required this.onMonthChanged,
    required this.onYearChanged,
  });

  @override
  Widget build(BuildContext context) {
    Widget field(
      String label,
      TextEditingController c, {
      TextInputType? type,
      int? maxLen,
    }) {
      return TextField(
        controller: c,
        keyboardType: type,
        maxLength: maxLen,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          counterText: '',
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

    final years = List<int>.generate(12, (i) => DateTime.now().year + i);

    return Column(
      children: [
        field('Card holder name', holder),
        const SizedBox(height: 12),

        InputDecorator(
          decoration: InputDecoration(
            labelText: 'Brand',
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: const Color(0xFF17171A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: brand,
              dropdownColor: const Color(0xFF17171A),
              icon: const Icon(Icons.expand_more, color: Colors.white70),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
              onChanged: (v) {
                if (v != null) onBrandChanged(v);
              },
              items: const [
                DropdownMenuItem(value: 'Visa', child: Text('Visa')),
                DropdownMenuItem(value: 'Mastercard', child: Text('Mastercard')),
                DropdownMenuItem(value: 'Amex', child: Text('Amex')),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        
        field('Card number', number, type: TextInputType.number, maxLen: 19),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Exp month',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF17171A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: expMonth,
                    dropdownColor: const Color(0xFF17171A),
                    icon: const Icon(Icons.expand_more, color: Colors.white70),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                    onChanged: (v) {
                      if (v != null) onMonthChanged(v);
                    },
                    items: List.generate(
                      12,
                      (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text((i + 1).toString().padLeft(2, '0')),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Exp year',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF17171A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: expYear,
                    dropdownColor: const Color(0xFF17171A),
                    icon: const Icon(Icons.expand_more, color: Colors.white70),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                    onChanged: (v) {
                      if (v != null) onYearChanged(v);
                    },
                    items: years
                        .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                        .toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}



class _RowKV extends StatelessWidget {
  final String label;
  final String value;
  final bool strong;

  const _RowKV({required this.label, required this.value, this.strong = false});

  @override
  Widget build(BuildContext context) {
    final styleL = TextStyle(
      color: strong ? Colors.white : Colors.white70,
      fontSize: strong ? 18 : 15,
      fontWeight: strong ? FontWeight.w900 : FontWeight.w800,
    );
    final styleR = TextStyle(
      color: Colors.white,
      fontSize: strong ? 18 : 15,
      fontWeight: strong ? FontWeight.w900 : FontWeight.w900,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: styleL),
        Text(value, style: styleR),
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
