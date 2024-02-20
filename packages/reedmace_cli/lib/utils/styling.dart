import 'package:mason_logger/mason_logger.dart';

final String emSpace = String.fromCharCode(0x2003);

extension ModuleInfo on Logger {
  void moduleInfo(String module, String message) {
    info("[${module.toUpperCase()}]$emSpace$message",
        style: moduleStyle(messageColor: white, moduleColor: green));
  }

  void moduleErr(String module, String message) {
    err("[${module.toUpperCase()}]$emSpace$message",
        style: moduleStyle(messageColor: red, moduleColor: red));
  }

  void moduleDetail(String module, String message) {
    detail("[${module.toUpperCase()}]$emSpace$message",
        style: moduleStyle(messageColor: darkGray, moduleColor: darkGray));
  }
}

String? Function(String?) moduleStyle({
  AnsiCode moduleColor = green,
  AnsiCode messageColor = white,
}) =>
    (m) =>
        _moduleStyle(m, moduleColor: moduleColor, messageColor: messageColor);

String? _moduleStyle(
  String? m, {
  AnsiCode moduleColor = green,
  AnsiCode messageColor = white,
}) {
  if (m == null) return null;
  var content = m.split(String.fromCharCode(0x2003));
  var module = content[0].substring(1, content[0].length - 1);
  var message = content.skip(1).join(" ");
  return "${darkGray.wrap("[")}${moduleColor.wrap(module.toUpperCase())}${darkGray.wrap("]")} ${messageColor.wrap(message)}";
}
