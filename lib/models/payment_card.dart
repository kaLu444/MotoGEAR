class PaymentCard {
  final String holderName;
  final String brand;
  final String number;
  final int expMonth;
  final int expYear;

  PaymentCard({
    required this.holderName,
    required this.brand,
    required this.number,
    required this.expMonth,
    required this.expYear,
  });

  bool get isValid {
    final n = number.replaceAll(' ', '').trim();
    final onlyDigits = RegExp(r'^\d+$').hasMatch(n);
    final lenOk = n.length >= 13 && n.length <= 19;
    return holderName.trim().isNotEmpty &&
        brand.trim().isNotEmpty &&
        onlyDigits &&
        lenOk &&
        expMonth >= 1 &&
        expMonth <= 12 &&
        expYear >= 2000;
  }

  Map<String, dynamic> toMap() => {
        'holderName': holderName,
        'brand': brand,
        'number': number,
        'expMonth': expMonth,
        'expYear': expYear,
      };

  factory PaymentCard.fromMap(Map<String, dynamic> m) => PaymentCard(
        holderName: (m['holderName'] ?? '') as String,
        brand: (m['brand'] ?? '') as String,
        number: (m['number'] ?? '') as String,
        expMonth: (m['expMonth'] ?? 1) as int,
        expYear: (m['expYear'] ?? 2000) as int,
      );

  PaymentCard copyWith({
    String? holderName,
    String? brand,
    String? number,
    int? expMonth,
    int? expYear,
  }) {
    return PaymentCard(
      holderName: holderName ?? this.holderName,
      brand: brand ?? this.brand,
      number: number ?? this.number,
      expMonth: expMonth ?? this.expMonth,
      expYear: expYear ?? this.expYear,
    );
  }
}
