class Campaign {
  final String id;
  final String name;
   final String? clientLogoUrl;
  final String description;
  final DateTime startDate;
  final DateTime endDate;

  Campaign({
    required this.id,
    required this.name,
     this.clientLogoUrl,
    required this.description,
    required this.startDate,
    required this.endDate,
  });
}
