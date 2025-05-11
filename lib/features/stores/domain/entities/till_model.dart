import 'package:equatable/equatable.dart';

class Till extends Equatable {
  final String id;
  final bool isOccupied;
  final int number;
  final String? imageUrl;
  final List<String> imageUrls;

  const Till({
    required this.id,
    required this.isOccupied,
    required this.number,
    this.imageUrl,
    this.imageUrls = const [],
  });

  @override
  List<Object?> get props => [id, isOccupied, number, imageUrl, imageUrls];

  Till copyWith({
    String? id,
    bool? isOccupied,
    int? number,
    String? imageUrl,
    List<String>? imageUrls,
  }) {
    return Till(
      id: id ?? this.id,
      isOccupied: isOccupied ?? this.isOccupied,
      number: number ?? this.number,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isOccupied': isOccupied,
      'number': number,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
    };
  }

  factory Till.fromMap(Map<String, dynamic> map) {
    return Till(
      id: map['id'] ?? '',
      isOccupied: map['isOccupied'] ?? false,
      number: map['number'] ?? 0,
      imageUrl: map['imageUrl'],
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
    );
  }
}
