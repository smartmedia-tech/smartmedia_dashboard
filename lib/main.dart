import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smartmedia_campaign_manager/firebase_options.dart';
import 'package:smartmedia_campaign_manager/features/auth/data/repositories/auth_repository.dart';
import 'package:smartmedia_campaign_manager/features/auth/domain/usecases/auth_usecases.dart';
import 'package:smartmedia_campaign_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smartmedia_campaign_manager/config/theme/theme_controller.dart';
import 'package:smartmedia_campaign_manager/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final authRepository = AuthRepository();
  final authUseCases = AuthUseCases(authRepository: authRepository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        Provider<AuthUseCases>.value(value: authUseCases),
      ],
      child: Builder(
        builder: (context) => BlocProvider(
          create: (_) => AuthBloc(authUseCases: context.read<AuthUseCases>()),
          child: const App(),
        ),
      ),
    ),
  );
}
