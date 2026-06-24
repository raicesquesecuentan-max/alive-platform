import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../services/accessibility_service.dart';
import '../theme/app_theme.dart';

class AccessibilityMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AccessibilityService>(
      builder: (context, accessibilityService, _) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Encabezado
                Center(
                  child: Text(
                    'accessibility_settings'.tr(),
                    style: TextStyle(
                      fontSize: 22 * accessibilityService.textScaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Contraste alto
                _buildAccessibilitySwitch(
                  context,
                  'high_contrast'.tr(),
                  accessibilityService.highContrastMode,
                  (value) {
                    accessibilityService.setHighContrastMode(value);
                  },
                  accessibilityService,
                ),
                SizedBox(height: 16),

                // Texto grande
                _buildAccessibilitySwitch(
                  context,
                  'large_text'.tr(),
                  accessibilityService.largeTextEnabled,
                  (value) {
                    accessibilityService.setLargeTextEnabled(value);
                  },
                  accessibilityService,
                ),
                SizedBox(height: 24),

                // Ajustar tamaño de texto
                _buildTextScaleSlider(context, accessibilityService),
                SizedBox(height: 24),

                // Opciones de retroalimentación háptica
                _buildHapticOptions(context, accessibilityService),
                SizedBox(height: 24),

                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          accessibilityService.resetToDefaults();
                          Navigator.pop(context);
                        },
                        child: Text('restablecer'.tr()),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('cerrar'.tr()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccessibilitySwitch(
    BuildContext context,
    String label,
    bool value,
    Function(bool) onChanged,
    AccessibilityService service,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16 * service.textScaleFactor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildTextScaleSlider(
    BuildContext context,
    AccessibilityService service,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'text_size'.tr(),
          style: TextStyle(
            fontSize: 16 * service.textScaleFactor,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Text(
              'A',
              style: TextStyle(fontSize: 12),
            ),
            Expanded(
              child: Slider(
                value: service.textScaleFactor,
                min: 0.8,
                max: 2.0,
                divisions: 12,
                onChanged: (value) {
                  service.setTextScaleFactor(value);
                },
                activeColor: AppTheme.primaryColor,
              ),
            ),
            Text(
              'A',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHapticOptions(
    BuildContext context,
    AccessibilityService service,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'haptic_feedback'.tr(),
          style: TextStyle(
            fontSize: 16 * service.textScaleFactor,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.favorite_border),
              label: Text('Light'),
              onPressed: () {
                service.sendHapticFeedback(HapticFeedbackType.light);
              },
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.favorite),
              label: Text('Medium'),
              onPressed: () {
                service.sendHapticFeedback(HapticFeedbackType.medium);
              },
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.favorite),
              label: Text('Heavy'),
              onPressed: () {
                service.sendHapticFeedback(HapticFeedbackType.heavy);
              },
            ),
          ],
        ),
      ],
    );
  }
}
