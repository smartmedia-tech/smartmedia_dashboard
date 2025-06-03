// lib/injection_container.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/usecases/upload_image.dart';
import 'package:smartmedia_campaign_manager/features/reports/data/repositories/reports_repository_impl.dart';
import 'package:smartmedia_campaign_manager/features/reports/domain/repositories/reports_repository.dart';
import 'package:smartmedia_campaign_manager/features/reports/domain/usecases/delete_report_usecase.dart';
import 'package:smartmedia_campaign_manager/features/reports/domain/usecases/generate_report_usecase.dart';
import 'package:smartmedia_campaign_manager/features/reports/domain/usecases/get_reports_usecase.dart';
import 'package:smartmedia_campaign_manager/features/reports/presentation/bloc/reports_bloc.dart';

// Data Layer
import 'features/campaign/data/repositories/campaign_repository_impl.dart';
import 'features/campaign/data/datasources/campaign_remote_data_source.dart';
import 'features/stores/data/datasources/store_remote_data_source.dart';
import 'features/stores/data/repositories/store_repository_impl.dart';

// Domain Layer
import 'features/campaign/domain/repositories/campaign_repository.dart';
import 'features/campaign/domain/usecases/create_campaign.dart';
import 'features/campaign/domain/usecases/get_campaigns.dart';
import 'features/campaign/domain/usecases/get_campaign.dart';
import 'features/campaign/domain/usecases/update_campaign.dart';
import 'features/campaign/domain/usecases/delete_campaign.dart';
import 'features/campaign/domain/usecases/change_campaign_status.dart';
import 'features/stores/domain/repositories/store_repository.dart';

// Presentation Layer
import 'features/campaign/presentation/bloc/campaign_bloc.dart';
import 'features/stores/presentation/bloc/stores_bloc.dart';

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

  sl.registerLazySingleton<StoreRemoteDataSource>(
    () => StoreRemoteDataSource(
      firestore: sl<FirebaseFirestore>(),
      storage: sl<FirebaseStorage>(),
    ),
  );
    sl.registerLazySingleton<ReportsRepository>(
    () => ReportsRepositoryImpl(sl()),
  );

  // 🏗️ Repository
  sl.registerLazySingleton<CampaignRepository>(
    () => CampaignRepositoryImpl(sl<CampaignRemoteDataSource>()),
  );

  sl.registerLazySingleton<StoreRepository>(
    () => StoreRepositoryImpl(sl<StoreRemoteDataSource>()),
  );

  // 📤 Use Cases
   sl.registerLazySingleton(() => GenerateReportUseCase(sl()));
  sl.registerLazySingleton(() => GetReportsUseCase(sl()));
  sl.registerLazySingleton(() => DeleteReportUseCase(sl()));
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
    sl.registerFactory(() => ReportsBloc(sl()));

  // Register StoresBloc factory
  sl.registerFactory(
    () => StoresBloc(
      storeRepository: sl<StoreRepository>(),
    ),
  );
}
