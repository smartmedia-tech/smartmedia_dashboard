import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/till_model.dart';

class Store extends Equatable {
  final String id;
  final String name;
  final String region;
  final String siteNumber;
  final String? imageUrl;
  final List<Till> tills;
  final DateTime createdAt;

  const Store({
    required this.id,
    required this.name,
    required this.region,
    required this.siteNumber,
    this.imageUrl,
    required this.tills,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, name, region, siteNumber, imageUrl, tills, createdAt];

  Store copyWith({
    String? id,
    String? name,
    String? region,
    String? siteNumber,
    String? imageUrl,
    List<Till>? tills,
    DateTime? createdAt,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      region: region ?? this.region,
      siteNumber: siteNumber ?? this.siteNumber,
      imageUrl: imageUrl ?? this.imageUrl,
      tills: tills ?? this.tills,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'region': region,
      'siteNumber': siteNumber,
      'imageUrl': imageUrl,
      'tills': tills.map((till) => till.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Store.fromMap(Map<String, dynamic> map) {
    List<Till> parsedTills = [];
    if (map['tills'] != null) {
      parsedTills =
          List<Till>.from((map['tills'] as List).map((x) => Till.fromMap(x)));
    }

    DateTime parsedDate = DateTime.now();
    if (map['createdAt'] != null) {
      if (map['createdAt'] is Timestamp) {
        parsedDate = (map['createdAt'] as Timestamp).toDate();
      } else if (map['createdAt'] is DateTime) {
        parsedDate = map['createdAt'] as DateTime;
      } else if (map['createdAt'] is String) {
        parsedDate = DateTime.parse(map['createdAt'] as String);
      }
    }

    return Store(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      region: map['region'] ?? '',
      siteNumber: map['siteNumber'] ?? '',
      imageUrl: map['imageUrl'],
      tills: parsedTills,
      createdAt: parsedDate,
    );
  }

  factory Store.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Store.fromMap({...data, 'id': doc.id});
  }

  int get totalTills => tills.length;
  int get occupiedTills => tills.where((till) => till.isOccupied).length;
  int get availableTills => totalTills - occupiedTills;
}
