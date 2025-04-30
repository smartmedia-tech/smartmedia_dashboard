import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmedia_campaign_manager/config/theme/theme_controller.dart';
import 'package:smartmedia_campaign_manager/wrapper/wrapper.dart';

class App extends StatelessWidget {
  const App({super.key});

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
