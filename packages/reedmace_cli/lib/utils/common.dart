import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:pointycastle/api.dart';

File getPathFromRoot(String path) {
  return File(path).absolute;
}

void createReedmaceCache() {
  var reedmaceCache = Directory(getPathFromRoot(".reedmace").path);
  if (!reedmaceCache.existsSync()) {
    reedmaceCache.createSync();
  }
}

String? readReedmaceCache(String subPath) {
  createReedmaceCache();
  var file = getPathFromRoot(path.join(".reedmace", subPath));
  if (file.existsSync()) {
    return file.readAsStringSync();
  }
  return null;
}

void writeReedmaceCache(String subPath, String content) {
  createReedmaceCache();
  var file = getPathFromRoot(path.join(".reedmace", subPath));
  file.createSync();
  file.writeAsStringSync(content);
}

String readCacheHash(String subPath) {
  var value = readReedmaceCache(subPath);
  if (value == null) {
    return "";
  }
  var digest = Digest("SHA-256");
  var hash = digest.process(utf8.encode(value));
  return bin2hex(hash);
}

String hashFile(File file) {
  if (!file.existsSync()) {
    return "";
  }
  var digest = Digest("SHA-256");
  var hash = digest.process(utf8.encode(file.readAsStringSync()));
  return bin2hex(hash);
}

String combineHashes(List<String> hashes) {
  var digest = Digest("SHA-256");
  var hash = digest.process(utf8.encode(hashes.join()));
  return bin2hex(hash);
}

String bin2hex(List<int> data) {
  return data.map((e) => e.toRadixString(16).padLeft(2, "0")).join();
}

String get currentApiDefHash => combineHashes(
    [readCacheHash("api_specs.json"), readCacheHash("mapping.json")]);
