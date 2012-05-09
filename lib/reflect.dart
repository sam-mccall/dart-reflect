// Copyright 2012 Google Inc.
// Licensed under the Apache License, Version 2.0 (the "License")
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

#library('reflect');

#import('dart-ext:dart_reflect');
#import('dart:uri');
#import('dart:io');

/// Represents a Dart library.
class Library {
  final String url;
  var _handle;

  /// Wraps the library with the specified URL, loading it if it doesn't exist.
  /// [url] may be absolute or relative to the working directory.
  /// Throws an exception if the library doesn't exist and can't be loaded.
  Library(String url) : this.url = url {
    _handle = _init(
      new Uri(scheme:"file", path:"${new Directory.current().path}/").resolve(url).toString(),
      () => new File(url).readAsTextSync());
  }

  _init(url, loader) native "Library_Init";

  /// Returns a [Callable] wrapping the named top-level function.
  /// Does not verify that the function exists.
  Callable method(String name) => new Callable.fromHandler(
      (args) => _invoke(_handle, name, args),
      "Function $name");

  /// Returns a [Class] wrapping the named class.
  /// Throws an exception if the class doesn't exist.
  Class getClass(String name) => new Class._internal(this, name);

  toString() => "Library $url";
}

/// Represents a Dart class.
class Class {
  final Library library;
  final String name;
  var _handle;

  Class._internal(Library library, String name) : this.library = library, this.name = name {
    _handle = _init(library._handle, name);
  }

  _init(library, name) native "Class_Init";
  static _construct(klass, name, args) native "Class_Construct";

  /// Returns a [Callable] wrapping the named static method on this class.
  /// Does not verify that the method exists.
  Callable method(String name) => new Callable.fromHandler(
      (args) => _invoke(_handle, name, args),
      "Method ${this.name}.$name");

  /// Returns a [Callable] wrapping the (optionally named) constructor of this class.
  /// Does not verify that the constructor exists.
  Callable constructor([String name]) => new Callable.fromHandler(
      (args) => _construct(_handle, name, args),
      (name == null) ? "new ${this.name}" : "Constructor ${this.name}.$name");

  toString() => "Class $name";
}

/// Wraps a Dart object.
class Instance {
  final value;
  var _handle;

  /// Returns an [Instance] wrapping [value].
  Instance.wrap(value) : this.value = value {
    _handle = _init(value);
  }

  _init(value) native "Instance_Init";

  /// Returns a [Callable] wrapping the named instance method.
  /// Does not verify that the method exists.
  Callable method(String name) => new Callable.fromHandler(
      (args) => _invoke(_handle, name, args), 
      "Method ($value).$name");

  toString() => "Instance $value";
}

/// A closure-like object - a function, static method, or bound instance method.
/// It can be invoked as `callable.call(arg1, arg2)` or `callable.invoke([arg1, arg2])`.
class Callable {
  final _handler, _closure, _description;

  /// Creates a [Callable] wrapping a [handler], which is a closure taking
  /// its arguments as a [List].
  Callable.fromHandler(handler(List args), [description]) :
      _handler = handler, _closure = null, _description = description;

  /// Creates a callable wrapping the [closure].
  Callable.fromClosure(closure, [description]) :
      _handler = null, _closure = closure, _description = description;

  /// Invokes this callable using [args] as the arguments.
  invoke(List args) {
    if (_closure != null) return _callClosure(_closure, args);
    return _handler(args);
  }

  /// Handles the variadic 'call' method by delegating to [invoke].
  noSuchMethod(method, args) {
    if (method == "call") return invoke(args);
    return super.noSuchMethod(method, args);
  }

  toString() => (_description == null) ? super.toString() : _description;

  static _callClosure(closure, args) native "CallClosure";
}

_invoke(obj, name, args) native "Invoke";
