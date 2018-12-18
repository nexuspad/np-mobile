class NPError implements Exception {
  static const INVALID_SESSION = "INVALID_SESSION";

  String _errorCode;
  String _detail;

  NPError({cause, detail = ''}) {
    _errorCode = cause;
    _detail = detail;
  }

  String get errorCode => _errorCode;
  String get detail => _detail;
  set detail(value) => _detail = value;

  @override
  String toString() {
    return '[$_errorCode] $_detail';
  }
}