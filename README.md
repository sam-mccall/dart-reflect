dart-reflect: Reflection shim for the Dart VM
=============================================

Dart's mirror-based reflection APIs are not yet available.
This library provides some basic operations which are available through the Dart native API.

# Example
    #import('lib/reflect.dart');
    // Both equivalent to print("Hello, world!");
    new Library('dart:core').method('print').call("Hello, world!");
    new Library('dart:core').method('print').invoke(["Hello, world!"]);

    // Equivalent to new Future.immediate("now");
    new Library('dart:core').getClass('Future').constructor('immediate').call('now');

    // Equivalent to [1,2,3].length;
    new Instance.wrap([1,2,3]).method('get:length').call();

    // Libraries are loaded if needed
    new Library("plugins/$plugin.dart").method('initialize').call();

# Documentation

Yes! [Here's the dartdoc](http://sam-mccall.github.com/dart-reflect/).

# Building (Linux/Mac)

You'll need:
  * Dart SDK
  * g++ toolchain.

Either edit build.sh to point to the SDK, or set the environment variable DART_SDK.

## Building the library

    ./build.sh

## Generating documentation

    ./build.sh doc

## Running tests

    ./build.sh test

# Building (Windows)

You'll need:

  * Dart SDK
  * dart.lib, the Dart native API library. You can obtain this by compiling Dart from source or grab [this version](https://github.com/downloads/sam-mccall/dart-sqlite/dart.lib) (last updated: 2012-04-24)
  * Visual C++ 2008. The [free version](http://msdn.microsoft.com/en-us/express/future/bb421473) works fine.

## Building the library 

Edit build.bat to specify where you extracted the Dart sources.

    C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\vcvarsall.bat
    build

## Generating the documentation

    build doc

## Running tests

    build test

# Legal stuff
Copyright 2012 Google Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
