import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../services/voice_service.dart';
import '../services/accessibility_service.dart';
import '../theme/app_theme.dart';
import '../widgets/voice_button.dart';
import '../widgets/accessibility_menu.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late VoiceService _voiceService;
  late AccessibilityService _accessibilityService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _voiceService = context.read<VoiceService>();
      _accessibilityService = context.read<AccessibilityService>();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('alive_voice_app'.tr()),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.accessibility),
            tooltip: 'accessibility_settings'.tr(),
            onPressed: () {
              _showAccessibilityMenu(context);
            },
          ),
        ],
      ),
      body: Consumer2<VoiceService, AccessibilityService>(
        builder: (context, voiceService, accessibilityService, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo/Título
                  _buildHeader(accessibilityService),
                  SizedBox(height: 32),

                  // Botón de micrófono principal
                  _buildVoiceButton(context, voiceService, accessibilityService),
                  SizedBox(height: 24),

                  // Texto reconocido
                  if (voiceService.recognizedText.isNotEmpty)
                    _buildRecognizedText(voiceService, accessibilityService),
                  SizedBox(height: 24),

                  // Información de estado
                  _buildStatusInfo(voiceService, accessibilityService),
                  SizedBox(height: 32),

                  // Botones secundarios
                  _buildSecondaryButtons(context, accessibilityService),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  Widget _buildHeader(AccessibilityService accessibilityService) {
    return Column(
      children: [
        Icon(
          Icons.mic_voice,
          size: 80,
          color: AppTheme.primaryColor,
        ),
        SizedBox(height: 16),
        Text(
          'bienvenido_alivé'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28 * accessibilityService.textScaleFactor,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'asistencia_voz'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16 * accessibilityService.textScaleFactor,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceButton(BuildContext context, VoiceService voiceService,
      AccessibilityService accessibilityService) {
    return VoiceButton(
      isListening: voiceService.isListening,
      onPressed: () async {
        if (voiceService.isListening) {
          await voiceService.stopListening();
        } else {
          await voiceService.startListening();
        }
      },
      speechLevel: voiceService.speechLevel,
    );
  }

  Widget _buildRecognizedText(VoiceService voiceService,
      AccessibilityService accessibilityService) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'texto_reconocido'.tr(),
            style: TextStyle(
              fontSize: 14 * accessibilityService.textScaleFactor,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            voiceService.recognizedText,
            style: TextStyle(
              fontSize: 18 * accessibilityService.textScaleFactor,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusInfo(VoiceService voiceService,
      AccessibilityService accessibilityService) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        voiceService.isListening ? 'escuchando'.tr() : 'listo'.tr(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14 * accessibilityService.textScaleFactor,
          color: voiceService.isListening ? Colors.green : Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSecondaryButtons(BuildContext context,
      AccessibilityService accessibilityService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          icon: Icon(Icons.language),
          label: Text('cambiar_idioma'.tr()),
          onPressed: () {
            _showLanguageMenu(context);
          },
        ),
        SizedBox(height: 12),
        ElevatedButton.icon(
          icon: Icon(Icons.settings),
          label: Text('configuración'.tr()),
          onPressed: () {
            _showSettings(context);
          },
        ),
        SizedBox(height: 12),
        ElevatedButton.icon(
          icon: Icon(Icons.info),
          label: Text('about'.tr()),
          onPressed: () {
            _showAbout(context);
          },
        ),
      ],
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'inicio'.tr(),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'historial'.tr(),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'perfil'.tr(),
        ),
      ],
      onTap: (index) {
        // Implementar navegación
      },
    );
  }

  void _showAccessibilityMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => AccessibilityMenu(),
    );
  }

  void _showLanguageMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('seleccionar_idioma'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Español'),
              onTap: () {
                context.setLocale(Locale('es'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('English'),
              onTap: () {
                context.setLocale(Locale('en'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Português'),
              onTap: () {
                context.setLocale(Locale('pt'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Quechua'),
              onTap: () {
                context.setLocale(Locale('qu'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('configuración'.tr()),
        content: Text('configuración_en_desarrollo'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cerrar'.tr()),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Alivé Voz',
      applicationVersion: '1.0.0',
      applicationLegalese: 'MIT License',
    );
  }
}
