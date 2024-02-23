import 'package:canister/canister.dart';
import 'package:lyell/lyell.dart';
import 'package:reedmace/reedmace.dart';

/// Base class for all request types.
/// Exists so that extensions can always access the context regardless of the request type.
abstract class ReqBase<T> {
  RequestContext get context;
  TypeCapture<T> get typeCapture => TypeToken<T>();
}


/// Arbitrary request that has to be received manually.
class Req<T> extends ReqBase<T> {
  final ReedmaceBodySerializer _bodySerializer;
  
  @override
  final RequestContext context;

  Req(this.context, this._bodySerializer);
  
  T? _cachedValue;

  Future<T> receive() async {
    if (_cachedValue != null) return _cachedValue!;
    T value = await _bodySerializer.deserialize(context.request.read());
    _cachedValue = value;
    return value;
  }

  static Req<T> assemblerCreate<T>(
      (RequestContext context, ReedmaceBodySerializer bodySerializer) arg) {
    return Req<T>(arg.$1, arg.$2);
  }

  static QualifiedTypeTree tree<T>() => QualifiedTypeTree.arg1<Req<T>, Req, T>();
}

/// A request that has automatically receives its value.
class ValReq<T> extends ReqBase<T> {
  
  final T value;
  
  @override
  final RequestContext context;

  ValReq(this.context, this.value);

  static ValReq<T> assemblerCreate<T>((RequestContext context, dynamic body) arg) {
    return ValReq<T>(arg.$1, arg.$2 as T);
  }

  static QualifiedTypeTree tree<T>() => QualifiedTypeTree.arg1<ValReq<T>, ValReq, T>();
}