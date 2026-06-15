import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class VoiceButton extends StatefulWidget {
  final bool isListening;
  final VoidCallback onPressed;
  final double speechLevel;

  VoiceButton({
    required this.isListening,
    required this.onPressed,
    this.speechLevel = 0.0,
  });

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.isListening) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(VoiceButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && !oldWidget.isListening) {
      _animationController.repeat(reverse: true);
    } else if (!widget.isListening && oldWidget.isListening) {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulsos de fondo
          if (widget.isListening) ...[
            _buildPulseRing(120, 0.3),
            _buildPulseRing(160, 0.2),
            _buildPulseRing(200, 0.1),
          ],

          // Botón principal
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              );
            },
            child: GestureDetector(
              onTap: widget.onPressed,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isListening
                      ? Colors.red
                      : AppTheme.primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: (widget.isListening
                              ? Colors.red
                              : AppTheme.primaryColor)
                          .withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  widget.isListening ? Icons.stop : Icons.mic,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Visualizador de nivel de voz
          if (widget.isListening && widget.speechLevel > 0)
            CustomPaint(
              painter: VoiceLevelPainter(
                level: widget.speechLevel,
              ),
              size: Size(150, 150),
            ),
        ],
      ),
    );
  }

  Widget _buildPulseRing(double size, double opacity) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: size * _pulseAnimation.value,
          height: size * _pulseAnimation.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(opacity),
              width: 2,
            ),
          ),
        );
      },
    );
  }
}

class VoiceLevelPainter extends CustomPainter {
  final double level;
  static const int bars = 12;

  VoiceLevelPainter({required this.level});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.6)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < bars; i++) {
      final angle = (2 * 3.14159 / bars) * i;
      final height = radius * (0.3 + level * 0.7 * (1 + (i % 2) * 0.2));

      final startOffset = Offset(
        center.dx + radius * 0.7 * Math.cos(angle),
        center.dy + radius * 0.7 * Math.sin(angle),
      );

      final endOffset = Offset(
        center.dx + height * Math.cos(angle),
        center.dy + height * Math.sin(angle),
      );

      canvas.drawLine(startOffset, endOffset, paint);
    }
  }

  @override
  bool shouldRepaint(VoiceLevelPainter oldDelegate) {
    return oldDelegate.level != level;
  }
}

class Math {
  static double cos(double radians) => (Math.cos(radians));
  static double sin(double radians) => (Math.sin(radians));
}
