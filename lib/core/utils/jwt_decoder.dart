import 'dart:convert';

class JwtDecoder {
  static Map<String, dynamic>? decode(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;

    try {
      String payload = parts[1];
      // Normalize base64 padding
      int mod = payload.length % 4;
      if (mod > 0) {
        payload += '=' * (4 - mod);
      }
      
      // Replace base64url characters with base64 standard characters
      payload = payload.replaceAll('-', '+').replaceAll('_', '/');
      
      final decodedBytes = base64.decode(payload);
      final decodedString = utf8.decode(decodedBytes);
      return json.decode(decodedString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  static bool isExpired(String token) {
    final decoded = decode(token);
    if (decoded == null) return true;
    
    final exp = decoded['exp'] as int?;
    if (exp == null) return false;
    
    final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    return DateTime.now().isAfter(expirationDate);
  }
}
