// lib/injection_container.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/usecases/upload_image.dart';

// Data Layer
import 'features/campaign/data/repositories/campaign_repository_impl.dart';
import 'features/campaign/data/datasources/campaign_remote_data_source.dart';

// Domain Layer
import 'features/campaign/domain/repositories/campaign_repository.dart';
import 'features/campaign/domain/usecases/create_campaign.dart';
import 'features/campaign/domain/usecases/get_campaigns.dart';
import 'features/campaign/domain/usecases/get_campaign.dart';
import 'features/campaign/domain/usecases/update_campaign.dart';
import 'features/campaign/domain/usecases/delete_campaign.dart';
import 'features/campaign/domain/usecases/change_campaign_status.dart';

// Presentation Layer
import 'features/campaign/presentation/bloc/campaign_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // 🔁 External
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);

  // 📦 Data Source
  sl.registerLazySingleton<CampaignRemoteDataSource>(
    () => CampaignRemoteDataSource(
        sl<FirebaseFirestore>(), sl<FirebaseStorage>()),
  );

  // 🏗️ Repository
  sl.registerLazySingleton<CampaignRepository>(
    () => CampaignRepositoryImpl(sl<CampaignRemoteDataSource>()),
  );

  // 📤 Use Cases
  sl.registerLazySingleton(() => CreateCampaign(sl<CampaignRepository>()));
  sl.registerLazySingleton(() => GetCampaigns(sl<CampaignRepository>()));
  sl.registerLazySingleton(() => GetCampaign(sl<CampaignRepository>()));
  sl.registerLazySingleton(() => UpdateCampaign(sl<CampaignRepository>()));
  sl.registerLazySingleton(() => DeleteCampaign(sl<CampaignRepository>()));
  sl.registerLazySingleton(
      () => ChangeCampaignStatus(sl<CampaignRepository>()));
  sl.registerLazySingleton(() => UploadCampaignImage(sl<CampaignRepository>()));

  // 🧠 Bloc
  sl.registerFactory(
    () => CampaignBloc(
      createCampaign: sl<CreateCampaign>(),
      getCampaigns: sl<GetCampaigns>(),
      getCampaign: sl<GetCampaign>(),
      updateCampaign: sl<UpdateCampaign>(),
      deleteCampaign: sl<DeleteCampaign>(),
      changeCampaignStatus: sl<ChangeCampaignStatus>(),
      uploadCampaignImage: sl<UploadCampaignImage>(),
    ),
  );
}
