// lib/injection_container_app.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'package:smartmedia_campaign_manager/features/campaign/presentation/bloc/campaign_bloc.dart';
import 'package:smartmedia_campaign_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smartmedia_campaign_manager/features/auth/data/repositories/auth_repository.dart';
import 'package:smartmedia_campaign_manager/features/auth/domain/usecases/auth_usecases.dart';
import 'package:smartmedia_campaign_manager/config/theme/theme_controller.dart';
import 'package:smartmedia_campaign_manager/features/campaign/presentation/bloc/campaign_event.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/bloc/stores_bloc.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/bloc/stores_event.dart';
import 'package:smartmedia_campaign_manager/wrapper/wrapper.dart';

import 'injection_container.dart';

class InjectionContainerApp extends StatelessWidget {
  const InjectionContainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository();
    final authUseCases = AuthUseCases(authRepository: authRepository);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        Provider<AuthUseCases>.value(value: authUseCases),
      ],
      child: Builder(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (_) =>
                  AuthBloc(authUseCases: context.read<AuthUseCases>()),
            ),
            BlocProvider<CampaignBloc>(
              create: (_) => sl<CampaignBloc>()..add(const LoadCampaigns()),
            ),
            // Add StoresBloc provider
            BlocProvider<StoresBloc>(
              create: (_) => sl<StoresBloc>()..add(LoadStores()),
            ),
          ],
          child: Consumer<ThemeController>(
            builder: (context, themeController, _) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                themeMode: themeController.themeMode,
                theme: ThemeData.light(),
                darkTheme: ThemeData.dark(),
                home: const Wrapper(),
              );
            },
          ),
        ),
      ),
    );
  }
}
