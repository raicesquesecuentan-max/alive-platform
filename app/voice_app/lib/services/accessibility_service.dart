import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

class AccessibilityService extends ChangeNotifier {
  final Logger _logger = Logger();
  
  bool _screenReaderEnabled = false;
  bool _highContrastMode = false;
  bool _largeTextEnabled = false;
  double _textScaleFactor = 1.0;
  
  bool get screenReaderEnabled => _screenReaderEnabled;
  bool get highContrastMode => _highContrastMode;
  bool get largeTextEnabled => _largeTextEnabled;
  double get textScaleFactor => _textScaleFactor;

  AccessibilityService() {
    _detectAccessibilitySettings();
  }

  /// Detectar configuración de accesibilidad del sistema
  Future<void> _detectAccessibilitySettings() async {
    try {
      // Aquí puedes agregar lógica para detectar configuraciones del sistema
      _logger.i('Configuración de accesibilidad detectada');
      notifyListeners();
    } catch (e) {
      _logger.e('Error detectando configuración de accesibilidad: $e');
    }
  }

  /// Activar/desactivar contraste alto
  void setHighContrastMode(bool enabled) {
    _highContrastMode = enabled;
    _logger.i('Contraste alto: $enabled');
    notifyListeners();
  }

  /// Activar/desactivar texto grande
  void setLargeTextEnabled(bool enabled) {
    _largeTextEnabled = enabled;
    _textScaleFactor = enabled ? 1.5 : 1.0;
    _logger.i('Texto grande: $enabled (escala: $_textScaleFactor)');
    notifyListeners();
  }

  /// Establecer factor de escala de texto personalizado
  void setTextScaleFactor(double factor) {
    _textScaleFactor = factor.clamp(0.8, 2.0);
    _logger.i('Factor de escala de texto: $_textScaleFactor');
    notifyListeners();
  }

  /// Anunciar elemento para screen readers
  Future<void> announceForAccessibility(String message) async {
    try {
      const platform = MethodChannel('com.example.alive/accessibility');
      await platform.invokeMethod('announce', {'message': message});
      _logger.i('Anunciado: $message');
    } catch (e) {
      _logger.e('Error anunciando para accesibilidad: $e');
    }
  }

  /// Enviar feedback háptico
  Future<void> sendHapticFeedback(HapticFeedbackType type) async {
    try {
      switch (type) {
        case HapticFeedbackType.light:
          await HapticFeedback.lightImpact();
          break;
        case HapticFeedbackType.medium:
          await HapticFeedback.mediumImpact();
          break;
        case HapticFeedbackType.heavy:
          await HapticFeedback.heavyImpact();
          break;
        case HapticFeedbackType.selection:
          await HapticFeedback.selectionClick();
          break;
      }
      _logger.i('Feedback háptico: $type');
    } catch (e) {
      _logger.e('Error enviando feedback háptico: $e');
    }
  }

  /// Modo de navegación gestual para ciegos
  void enableGestureNavigation(bool enabled) {
    _logger.i('Navegación gestual: $enabled');
    // Implementar lógica de gestos personalizados
    notifyListeners();
  }

  /// Configuración de acceso rápido
  Map<String, dynamic> getAccessibilitySettings() {
    return {
      'screenReaderEnabled': _screenReaderEnabled,
      'highContrastMode': _highContrastMode,
      'largeTextEnabled': _largeTextEnabled,
      'textScaleFactor': _textScaleFactor,
    };
  }

  /// Restaurar configuración predeterminada
  void resetToDefaults() {
    _screenReaderEnabled = false;
    _highContrastMode = false;
    _largeTextEnabled = false;
    _textScaleFactor = 1.0;
    _logger.i('Configuración de accesibilidad restablecida');
    notifyListeners();
  }
}

enum HapticFeedbackType {
  light,
  medium,
  heavy,
  selection,
}
