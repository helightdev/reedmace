
# Routes
## Babies First Route
In Reedmace, routes are defined using annotations on global functions. The routes are then
automatically registered with the server and their signatures are used to generate the OpenAPI
documentation and client library bindings.

All default http methods posses a custom annotation named after the method in uppercase, e.g. `@GET`,
`@POST`, `@PUT`, `@DELETE`, `@PATCH`. All other http methods can be used with the `@Route` annotation.

``` { .dart .annotate title="Simple Route" }
@GET("/hello")
Res<String>/*(2)!*/ hello(Req/*(1)!*/ req) {
  return Res.ok("Hello World!");
}
```

1. A request without a type parameter will be treated as having no defined body.
2. Defines the return type of the method that will be used as the response body.

### Request and Response Bodies
Request and response bodies are defined using the type parameter of the `Req` and `Res` classes.
The default `Req` class will only resolve the body of the request asynchronously when `receive` is
called. The `ValReq` class will resolve the body before the method is called and provide it as a
synchronously available value.

``` { .dart title="Required Body (synchronously available)" }
@POST("/user")
Res<User> create(ValReq<User> req) {
  return Res.ok(req.value);
}
```

## Parameters

Query parameters are defined by prefixing the parameter name with a `$`. The parameters may be of type
`String`, `int`, `bool` or their nullable counterparts.

``` { .dart .annotate title="Query Parameters" }
@GET("/hello")
Res<String> hello(Req req, String $name/*(1)!*/) {
  return Res.ok("Hello, ${$name}!");
}
```

1. Query parameters are defined by a `$` prefix and can be used as arguments in the method.

To define path parameters, simply include the parameter name in the route path prefixed by `:`.
The matching parameter in the method signature must have the same name and be of type `String`.

``` { .dart .annotate title="Path Parameters" }
@GET("/user/:userId/hello")
Res<String> hello(Req req, String userId/*(1)!*/) {
  return Res.ok("Hello, $userId!");
}
```

1. The argument for the path parameter is required to be a `String` and have the same name as the
   path parameter defined in the route path.

To define headers, simple include a parameter of type `String` with the header name as the parameter
that is prefixed with `$$`.

``` { .dart .annotate title="Header Parameters" }
@GET("/hello")
Res<String> hello(Req req, String $$authorization/*(1)!*/) {
  return Res.ok("Hello, ${$$authorization}!");
}
```

1. Header parameters are defined by a `$$` prefix and can be used as arguments in the method.

## Asynchronous Routes

All route functions can also be asynchronous and return a `Future<Res<T>>` instead of `Res<T>`.

``` { .dart title="Async Response" }
@GET("/user/:userId")
Future<Res<User>> getUser(Req req, String userId) async {
  var user = await db.getUser(userId);
  return Res.ok(user);
}
```

## Http Exceptions

Http exceptions can be easily created using the `HttpExceptions` factory class. The resulting responses
can either be returned directly or thrown. Throwing should only be used in contexts where
a `Res` object can't be returned.

``` { .dart .annotate title="Async Receive & Http Exceptions" }
@PUT("/user/:userId")
Future<Res<User>> getUser(Req<User> req, String userId) async {
  var user = await db.getUser(userId);
  if (user == null) return HttpExceptions.notFound();/*(1)!*/
  var patch = await req.receive(); /*(2)!*/
  var updated = await db.updateUser(userId, patch);
  return Res.ok(updated);
}
```

1. Can also be thrown with `throw HttpExceptions.notFound();` Only use throw if you are in a
   context where you can't return a `Res` object.
2. The `receive` method is used to receive the body of the request asynchronously. The type of
   the body is inferred from the type parameter of `Req`.