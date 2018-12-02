class NPError implements Exception {
  static const INVALID_SESSION = "INVALID_SESSION";

  String _errorCode;

  NPError(String cause) {
    _errorCode = cause;
  }
}