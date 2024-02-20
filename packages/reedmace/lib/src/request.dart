import 'package:canister/canister.dart';
import 'package:lyell/lyell.dart';
import 'package:reedmace/reedmace.dart';

class Req<T> {

  final ReedmaceBodySerializer _bodySerializer;
  final RequestContext context;

  Req(this.context, this._bodySerializer);

  TypeCapture<T> get typeCapture => TypeToken<T>();

  T? _cachedValue;

  Future<T> receive() async {
    if (_cachedValue != null) return _cachedValue!;
    T value = await _bodySerializer.deserialize(context.request.read());
    _cachedValue = value;
    return value;
  }

  static Req<T> assemblerCreate<T>((RequestContext context, ReedmaceBodySerializer bodySerializer) arg) {
    return Req<T>(arg.$1, arg.$2);
  }
}