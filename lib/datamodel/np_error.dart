class NPError {
  String _errorCode;

  NPError(String errorCode) {
    _errorCode = errorCode;
  }

  String get errorCode => _errorCode;
}