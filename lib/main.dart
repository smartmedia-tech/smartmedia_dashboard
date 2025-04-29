import 'package:smartmedia_campaign_manager/config/theme/theme_controller.dart';
import 'package:smartmedia_campaign_manager/features/auth/data/repositories/auth_repository.dart';
import 'package:smartmedia_campaign_manager/features/auth/domain/usecases/auth_usecases.dart';
import 'package:smartmedia_campaign_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smartmedia_campaign_manager/firebase_options.dart';

import 'package:smartmedia_campaign_manager/wrapper/wrapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Create dependencies

  final authRepository = AuthRepository();
  final authUseCases = AuthUseCases(authRepository: authRepository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        Provider<AuthUseCases>.value(value: authUseCases),
        BlocProvider(
          create: (context) =>
              AuthBloc(authUseCases: context.read<AuthUseCases>()),
        ),
     
     
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeController.themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const Wrapper(),
    );
  }
}
