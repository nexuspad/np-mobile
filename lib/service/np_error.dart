class NPError implements Exception {
  static const SERVICE_ERROR = 'SERVICE_ERROR';
  static const INVALID_SESSION = "INVALID_SESSION";

  String _errorCode;
  String _detail;

  NPError.statusCode(int statusCode) {
    if (statusCode == 401 || statusCode == 403) {
      _errorCode = INVALID_SESSION;
    } else {
      _errorCode = SERVICE_ERROR;
    }
  }

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