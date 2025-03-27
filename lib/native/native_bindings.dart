import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

// Cargar la librería dinámica (.so en Android, .dylib en iOS)
final DynamicLibrary nativeLib = Platform.isAndroid
    ? DynamicLibrary.open("libnative-lib.so") // Nombre del archivo en Android
    : DynamicLibrary.process(); // iOS carga la lib automáticamente

// Definir la función en Dart
typedef StringFromCppFunc = Pointer<Utf8> Function();
typedef StringFromCpp = Pointer<Utf8> Function();

final StringFromCpp stringFromCpp =
    nativeLib.lookup<NativeFunction<StringFromCppFunc>>("stringFromCpp").asFunction();
