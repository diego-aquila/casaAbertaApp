// lib/services/device_fingerprint.dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:universal_html/html.dart' as html;

class DeviceFingerprint {
  static String _cachedFingerprint = '';

  static Future<String> generate() async {
    if (_cachedFingerprint.isNotEmpty) {
      return _cachedFingerprint;
    }

    final components = <String>[];

    // Screen resolution
    components.add('${html.window.screen?.width}x${html.window.screen?.height}');
    
    // Timezone
    components.add(DateTime.now().timeZoneName);
    
    // Language
    components.add(html.window.navigator.language ?? 'unknown');
    
    // Platform
    components.add(html.window.navigator.platform ?? 'unknown');
    
    // User agent (simplified)
    final userAgent = html.window.navigator.userAgent ?? '';
    components.add(userAgent.length.toString());
    
    // Available fonts (aproximação)
    components.add(html.window.navigator.languages?.join(',') ?? 'unknown');
    
    // Color depth
    components.add(html.window.screen?.colorDepth?.toString() ?? 'unknown');
    
    // Pixel ratio
    components.add(html.window.devicePixelRatio.toString());

    // Gera hash único
    final fingerprint = components.join('|');
    final bytes = utf8.encode(fingerprint);
    final hash = sha256.convert(bytes);
    
    _cachedFingerprint = hash.toString().substring(0, 16); // Primeiros 16 chars
    return _cachedFingerprint;
  }
}