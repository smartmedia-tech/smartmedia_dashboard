// lib/injection_container.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'features/campaign/data/repositories/campaign_repository_impl.dart';
import 'features/campaign/data/datasources/campaign_remote_data_source.dart';
import 'features/campaign/domain/repositories/campaign_repository.dart';
import 'features/campaign/domain/usecases/create_campaign.dart';
import 'features/campaign/domain/usecases/get_campaign.dart';
import 'features/campaign/presentation/bloc/campaign_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // 🔁 External
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // 📦 Data Source
  sl.registerLazySingleton<CampaignRemoteDataSource>(
    () => CampaignRemoteDataSource(sl<FirebaseFirestore>()),
  );

  // 🏗️ Repository
  sl.registerLazySingleton<CampaignRepository>(
    () => CampaignRepositoryImpl(sl<CampaignRemoteDataSource>()),
  );

  // 📤 Use Cases
  sl.registerLazySingleton(() => CreateCampaign(sl<CampaignRepository>()));
  sl.registerLazySingleton(() => GetCampaigns(sl<CampaignRepository>()));

  // 🧠 Bloc
  sl.registerFactory(() => CampaignBloc(
        sl<CreateCampaign>(),
        sl<GetCampaigns>(),
      ));
}
