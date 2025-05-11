class Province {
  final String name;
  final String code;
  final String? abbreviation;

  const Province({
    required this.name,
    required this.code,
    this.abbreviation,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Province &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          code == other.code &&
          abbreviation == other.abbreviation;

  @override
  int get hashCode => name.hashCode ^ code.hashCode ^ abbreviation.hashCode;
}

class SAProvinces {
  static const List<Province> provinces = [
    Province(name: 'Eastern Cape', code: 'EC', abbreviation: 'EC'),
    Province(name: 'Free State', code: 'FS', abbreviation: 'FS'),
    Province(name: 'Gauteng', code: 'GP', abbreviation: 'GP'),
    Province(name: 'KwaZulu-Natal', code: 'KZN', abbreviation: 'KZN'),
    Province(name: 'Limpopo', code: 'LP', abbreviation: 'LP'),
    Province(name: 'Mpumalanga', code: 'MP', abbreviation: 'MP'),
    Province(name: 'Northern Cape', code: 'NC', abbreviation: 'NC'),
    Province(name: 'North West', code: 'NW', abbreviation: 'NW'),
    Province(name: 'Western Cape', code: 'WC', abbreviation: 'WC'),
  ];
}
