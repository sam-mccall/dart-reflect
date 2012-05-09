// Copyright 2012 Google Inc.
// Licensed under the Apache License, Version 2.0 (the "License")
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

#include "dart_util.h"

void scoped_finalizer(Dart_Handle handle, void* context) {
  Dart_DeletePersistentHandle(handle);
  Dart_DeletePersistentHandle(*((Dart_Handle*) context));
  free(context);
}

Dart_Handle scoped_handle(Dart_Handle scope, Dart_Handle target) {
  Dart_Handle result = CheckDartError(Dart_NewPersistentHandle(target));
  Dart_Handle* resultPtr = (Dart_Handle*) malloc(sizeof(Dart_Handle));
  *resultPtr = result;
  CheckDartError(Dart_NewWeakPersistentHandle(scope, resultPtr, scoped_finalizer));
  return result;
}

Dart_Handle wrap_handle(Dart_Handle raw) {
  int64_t result = (int64_t) raw;
  return Dart_NewInteger(result);
}

Dart_Handle unwrap_handle(Dart_Handle wrapped) {
  int64_t result;
  CheckDartError(Dart_IntegerToInt64(wrapped, &result));
  return (Dart_Handle) result;
}

DART_FUNCTION(Library_Init) {
  DART_ARGS_3(self, url, loader);
  Dart_Handle library = Dart_LookupLibrary(url);
  if (Dart_IsError(library)) {
    Dart_Handle source = CheckDartError(Dart_InvokeClosure(loader, 0, NULL));
    library = CheckDartError(Dart_LoadLibrary(url, source, Dart_Null()));
  }
  DART_RETURN(wrap_handle(scoped_handle(self, library)));
} 

DART_FUNCTION(Class_Init) {
  DART_ARGS_3(self, library, name);
  Dart_Handle klass = CheckDartError(Dart_GetClass(unwrap_handle(library), name));
  DART_RETURN(wrap_handle(scoped_handle(self, klass)));
} 

DART_FUNCTION(Instance_Init) {
  DART_ARGS_2(self, value);
  DART_RETURN(wrap_handle(scoped_handle(self, value)));
}

#define ARRAY_TO_ARGPTR(array, argptr, length) \
  intptr_t length; \
  CheckDartError(Dart_ListLength(array, &length)); \
  Dart_Handle argptr[length]; \
  for (int i = 0; i < length; i++) { \
    argptr[i] = Dart_ListGetAt(array, i); \
  }  

DART_FUNCTION(Class_Construct) {
  DART_ARGS_3(klass, name, args);
  ARRAY_TO_ARGPTR(args, argptr, length);
  DART_RETURN(CheckDartError(Dart_New(unwrap_handle(klass), name, length, argptr)));
}

DART_FUNCTION(Invoke) {
  DART_ARGS_3(target, name, args);
  ARRAY_TO_ARGPTR(args, argptr, length);
  DART_RETURN(CheckDartError(Dart_Invoke(unwrap_handle(target), name, length, argptr)));
}

DART_FUNCTION(CallClosure) {
  DART_ARGS_2(closure, args);
  ARRAY_TO_ARGPTR(args, argptr, length);
  DART_RETURN(CheckDartError(Dart_InvokeClosure(closure, length, argptr)));
}

DART_LIBRARY(reflect)
  EXPORT(Invoke, 3)
  EXPORT(Class_Construct, 3)
  EXPORT(CallClosure, 2)
  EXPORT(Instance_Init, 2)
  EXPORT(Library_Init, 3)
  EXPORT(Class_Init, 3)
DART_LIBRARY_END
