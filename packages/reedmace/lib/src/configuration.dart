import 'dart:io';

class HttpServerConfiguration {
  int port = 8080;
  InternetAddress address = InternetAddress.anyIPv4;
  SecurityContext? securityContext;
  int? backlog;
  bool shared = false;
  String? poweredByHeader = "Dart+package:reedmace/shelf";

  HttpServerConfiguration();

  factory HttpServerConfiguration.fromEnvironment() {
    return HttpServerConfiguration()
      ..port = _envPort
      ..address = InternetAddress(_envHost)
      ..securityContext = _envSecurityContext;
  }
}

SecurityContext? get _envSecurityContext {
  if (_envUseHttps) {
    var context = SecurityContext.defaultContext;
    context.useCertificateChain(_envCertificate,
        password:
            _envCertificatePassword.isEmpty ? null : _envCertificatePassword);
    context.usePrivateKey(_envPrivateKey,
        password:
            _envPrivateKeyPassword.isEmpty ? null : _envPrivateKeyPassword);
    return context;
  }
  return null;
}

const String _prefix = "REEDMACE";

const int _envPort = int.fromEnvironment("${_prefix}_PORT", defaultValue: 8080);
const String _envHost =
    String.fromEnvironment("${_prefix}_HOST", defaultValue: "localhost");

const bool _envUseHttps =
    bool.fromEnvironment("${_prefix}_USE_HTTPS", defaultValue: false);
const String _envCertificate =
    String.fromEnvironment("${_prefix}_CERTIFICATE", defaultValue: "cert.pem");
const String _envCertificatePassword =
    String.fromEnvironment("${_prefix}_CERTIFICATE_PASSWORD", defaultValue: "");
const String _envPrivateKey =
    String.fromEnvironment("${_prefix}_PRIVATE_KEY", defaultValue: "key.pem");
const String _envPrivateKeyPassword =
    String.fromEnvironment("${_prefix}_PRIVATE_KEY_PASSWORD", defaultValue: "");
