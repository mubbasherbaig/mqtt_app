import 'dart:convert';

/// Extracts a value from JSON payload using dot notation path.
/// e.g. jsonPath = "sensor.temperature", payload = '{"sensor":{"temperature":22.5}}'
/// Returns raw payload if jsonPath is empty or extraction fails.
String extractJsonValue(String payload, String jsonPath) {
  if (jsonPath.isEmpty) return payload;
  try {
    final decoded = jsonDecode(payload);
    // Remove leading $. or $ if present
    String path = jsonPath;
    if (path.startsWith(r'$.')) path = path.substring(2);
    else if (path.startsWith(r'$')) path = path.substring(1);

    final keys = path.split('.');
    dynamic value = decoded;
    for (final key in keys) {
      if (key.isEmpty) continue;
      if (value is Map) {
        value = value[key];
      } else {
        return payload;
      }
    }
    return value?.toString() ?? payload;
  } catch (_) {
    return payload;
  }
}

/// Builds publish payload by replacing <payload> in JSON pattern.
/// e.g. pattern = '{"channel":0,"value":<payload>}', value = '128'
/// Returns value as-is if pattern is empty.
String buildJsonPayload(String value, String pattern) {
  if (pattern.isEmpty) return value;
  return pattern.replaceAll('<payload>', value);
}