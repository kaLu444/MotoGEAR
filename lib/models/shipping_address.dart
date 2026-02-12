class ShippingAddress {
  final String fullName;
  final String phone;
  final String line1;
  final String city;
  final String postalCode;
  final String countryCode; // npr. "RS", "US"

  const ShippingAddress({
    required this.fullName,
    required this.phone,
    required this.line1,
    required this.city,
    required this.postalCode,
    required this.countryCode,
  });

  factory ShippingAddress.empty() => const ShippingAddress(
        fullName: '',
        phone: '',
        line1: '',
        city: '',
        postalCode: '',
        countryCode: 'RS',
      );

  bool get isValid =>
      fullName.trim().isNotEmpty &&
      phone.trim().isNotEmpty &&
      line1.trim().isNotEmpty &&
      city.trim().isNotEmpty &&
      postalCode.trim().isNotEmpty &&
      countryCode.trim().isNotEmpty;

  Map<String, dynamic> toMap() => {
        'fullName': fullName,
        'phone': phone,
        'line1': line1,
        'city': city,
        'postalCode': postalCode,
        'countryCode': countryCode,
        'updatedAt': DateTime.now().toIso8601String(),
      };

  factory ShippingAddress.fromMap(Map<String, dynamic> data) {
    return ShippingAddress(
      fullName: (data['fullName'] as String?) ?? '',
      phone: (data['phone'] as String?) ?? '',
      line1: (data['line1'] as String?) ?? '',
      city: (data['city'] as String?) ?? '',
      postalCode: (data['postalCode'] as String?) ?? '',
      countryCode: (data['countryCode'] as String?) ?? 'RS',
    );
  }

  ShippingAddress copyWith({
    String? fullName,
    String? phone,
    String? line1,
    String? city,
    String? postalCode,
    String? countryCode,
  }) {
    return ShippingAddress(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      line1: line1 ?? this.line1,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      countryCode: countryCode ?? this.countryCode,
    );
  }
}
