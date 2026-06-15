import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:logger/logger.dart';

class VoiceService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final Logger _logger = Logger();
  
  bool _isListening = false;
  bool _isInitialized = false;
  String _recognizedText = '';
  double _speechLevel = 0.0;
  
  bool get isListening => _isListening;
  bool get isInitialized => _isInitialized;
  String get recognizedText => _recognizedText;
  double get speechLevel => _speechLevel;

  VoiceService() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Inicializar Text-to-Speech
      await _tts.setLanguage('es-ES');
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      await _tts.setSpeechRate(0.8);

      // Inicializar Speech-to-Text
      bool available = await _speechToText.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
      );

      if (available) {
        _isInitialized = true;
        await speak('Alivé Voz iniciado. Listo para escuchar.');
        _logger.i('VoiceService inicializado correctamente');
      } else {
        _logger.e('Speech recognition no disponible');
      }
    } catch (e) {
      _logger.e('Error inicializando VoiceService: $e');
    }
    notifyListeners();
  }

  /// Hablar texto
  Future<void> speak(String text) async {
    try {
      await _tts.speak(text);
      _logger.i('Hablando: $text');
    } catch (e) {
      _logger.e('Error al hablar: $e');
    }
  }

  /// Comenzar escucha de voz
  Future<void> startListening({String locale = 'es_ES'}) async {
    if (!_isInitialized) {
      _logger.w('VoiceService no inicializado');
      return;
    }

    try {
      if (!_isListening) {
        _isListening = true;
        _recognizedText = '';
        await _speechToText.listen(
          onResult: _onSpeechResult,
          localeId: locale,
          listenFor: Duration(seconds: 30),
          pauseFor: Duration(seconds: 3),
          partialResults: true,
          cancelOnError: true,
        );
        await speak('Escuchando...');
        notifyListeners();
      }
    } catch (e) {
      _logger.e('Error iniciando escucha: $e');
      _isListening = false;
      notifyListeners();
    }
  }

  /// Detener escucha de voz
  Future<void> stopListening() async {
    try {
      if (_isListening) {
        await _speechToText.stop();
        _isListening = false;
        await speak('Búsqueda finalizada');
        notifyListeners();
      }
    } catch (e) {
      _logger.e('Error deteniendo escucha: $e');
    }
  }

  /// Cancelar escucha
  Future<void> cancelListening() async {
    try {
      await _speechToText.cancel();
      _isListening = false;
      _recognizedText = '';
      notifyListeners();
    } catch (e) {
      _logger.e('Error cancelando escucha: $e');
    }
  }

  void _onSpeechResult(result) {
    _recognizedText = result.recognizedWords;
    _speechLevel = result.confidence;
    _logger.i('Reconocido: $_recognizedText (confianza: $_speechLevel)');
    notifyListeners();
  }

  void _onSpeechStatus(String status) {
    _logger.i('Estado de voz: $status');
    if (status == 'notListening') {
      _isListening = false;
      notifyListeners();
    }
  }

  void _onSpeechError(error) {
    _logger.e('Error de voz: $error');
    _isListening = false;
    notifyListeners();
  }

  /// Cambiar idioma
  Future<void> setLanguage(String languageCode) async {
    try {
      String locale = _mapLanguageToLocale(languageCode);
      await _tts.setLanguage(locale);
      _logger.i('Idioma cambiado a: $locale');
    } catch (e) {
      _logger.e('Error cambiando idioma: $e');
    }
  }

  String _mapLanguageToLocale(String code) {
    const Map<String, String> localeMap = {
      'es': 'es-ES',
      'en': 'en-US',
      'pt': 'pt-BR',
      'qu': 'es-PE', // Quechua - usar español de Perú
    };
    return localeMap[code] ?? 'es-ES';
  }

  /// Ajustar velocidad de habla
  Future<void> setSpeechRate(double rate) async {
    try {
      await _tts.setSpeechRate(rate);
      _logger.i('Velocidad de voz ajustada a: $rate');
    } catch (e) {
      _logger.e('Error ajustando velocidad: $e');
    }
  }

  /// Ajustar volumen
  Future<void> setVolume(double volume) async {
    try {
      await _tts.setVolume(volume.clamp(0.0, 1.0));
      _logger.i('Volumen ajustado a: $volume');
    } catch (e) {
      _logger.e('Error ajustando volumen: $e');
    }
  }

  @override
  void dispose() {
    _tts.stop();
    _speechToText.cancel();
    super.dispose();
  }
}
