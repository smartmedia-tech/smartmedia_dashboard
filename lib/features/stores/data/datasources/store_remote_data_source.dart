import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/stores_model.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/till_model.dart';
import 'package:uuid/uuid.dart';

class StoreRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  StoreRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  CollectionReference get _storesCollection => _firestore.collection('stores');

  Stream<List<Store>> getStores() {
    return _storesCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Store.fromFirestore(doc))
            .whereType<Store>()
            .toList());
  }

  Future<Store?> getStore(String storeId) async {
    final doc = await _storesCollection.doc(storeId).get();
    return doc.exists ? Store.fromFirestore(doc) : null;
  }

  Future<void> addStore({
    required String name,
    required String region,
    required String siteNumber,
    required int tillCount,
    String? imageUrl,
  }) async {
    final storeId = const Uuid().v4();
    final tills = List.generate(
      tillCount,
      (index) => Till(
        id: 'till_${index + 1}',
        isOccupied: false,
        number: index + 1,
      ),
    );

    final storeData = {
      'id': storeId,
      'name': name,
      'region': region,
      'siteNumber': siteNumber,
      'tills': tills.map((till) => till.toMap()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
      if (imageUrl != null) 'imageUrl': imageUrl,
    };

    await _storesCollection.doc(storeId).set(storeData);
  }

  Future<void> updateStore(Store store) async {
    await _storesCollection.doc(store.id).update(store.toMap());
  }

  Future<void> deleteStore(String storeId) async {
    final store = await getStore(storeId);
    if (store?.imageUrl != null) {
      await _storage.refFromURL(store!.imageUrl!).delete();
    }
    await _storesCollection.doc(storeId).delete();
  }

  Future<String> uploadStoreImage(String storeId, File imageFile) async {
    final ref = _storage.ref().child('store_images/$storeId.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  Future<String> uploadTillImage(
    String storeId,
    String tillId,
    File imageFile, {
    String? fileName,
  }) async {
    final ref = _storage.ref().child(
        'till_images/$storeId/$tillId/${fileName ?? DateTime.now().millisecondsSinceEpoch.toString()}.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  Future<void> updateTillWithImage({
    required String storeId,
    required String tillId,
    required File imageFile,
  }) async {
    final store = await getStore(storeId);
    if (store == null) throw Exception('Store not found');

    final imageUrl = await uploadTillImage(storeId, tillId, imageFile);

    final updatedTills = store.tills.map((till) {
      if (till.id == tillId) {
        final updatedImages = [imageUrl, ...till.imageUrls];
        if (till.imageUrl != null) {
          updatedImages.add(till.imageUrl!);
        }
        return till.copyWith(
          imageUrl: imageUrl,
          imageUrls: updatedImages,
        );
      }
      return till;
    }).toList();

    await _firestore.collection('stores').doc(storeId).update({
      'tills': updatedTills.map((till) => till.toMap()).toList(),
    });
  }

  Future<List<String>> fetchTillImages({
    required String storeId,
    required String tillId,
  }) async {
    final store = await getStore(storeId);
    if (store == null) return [];

    final till = store.tills.firstWhere(
      (t) => t.id == tillId,
      orElse: () => throw Exception('Till not found'),
    );

    final images = <String>[];
    if (till.imageUrl != null) images.add(till.imageUrl!);
    images.addAll(till.imageUrls);

    return images;
  }

  Future<void> updateTillStatus({
    required String storeId,
    required String tillId,
    required bool isOccupied,
  }) async {
    final store = await getStore(storeId);
    if (store != null) {
      final updatedTills = store.tills.map((till) {
        if (till.id == tillId) {
          return till.copyWith(isOccupied: isOccupied);
        }
        return till;
      }).toList();

      await _firestore.collection('stores').doc(storeId).update({
        'tills': updatedTills.map((till) => till.toMap()).toList(),
      });
    } else {
      throw Exception('Store not found');
    }
  }

  Future<List<String>> getUniqueRegions() async {
    final snapshot = await _storesCollection.get();
    final stores =
        snapshot.docs.map((doc) => Store.fromFirestore(doc)).toList();

    final Set<String> regions = {};
    for (var store in stores) {
      if (store.region.isNotEmpty) {
        regions.add(store.region);
      }
    }

    return regions.toList()..sort();
  }
}
