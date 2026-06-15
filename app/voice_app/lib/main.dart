import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'services/voice_service.dart';
import 'services/accessibility_service.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar servicios de accesibilidad
  await EasyLocalization.ensureInitialized();
  
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('es'), Locale('en'), Locale('pt'), Locale('qu')],
      path: 'assets/translations',
      fallbackLocale: Locale('es'),
      child: MultiProvider(
        providers: [
          Provider<FlutterTts>(create: (_) => FlutterTts()),
          ChangeNotifierProvider<VoiceService>(
            create: (_) => VoiceService(),
          ),
          ChangeNotifierProvider<AccessibilityService>(
            create: (_) => AccessibilityService(),
          ),
        ],
        child: AliveVoiceApp(),
      ),
    ),
  );
}

class AliveVoiceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alivé Voz',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
