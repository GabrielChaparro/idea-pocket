import 'dart:convert';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

String errorMessage(Object error) {
  if (error is ApiException) {
    return error.message;
  }
  return 'No se pudo completar la operación.';
}

String responseErrorMessage(int statusCode, String body) {
  if (body.isNotEmpty) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
      }
    } catch (_) {
      return body;
    }
  }

  return switch (statusCode) {
    400 => 'La solicitud no es válida.',
    401 => 'La sesión no es válida. Vuelve a iniciar sesión.',
    403 => 'No tienes permiso para realizar esta acción.',
    404 => 'No se encontró el recurso.',
    409 => 'Ya existe un registro con esos datos.',
    >= 500 => 'El servidor tuvo un problema.',
    _ => 'No se pudo completar la operación.',
  };
}

