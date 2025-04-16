import 'dart:ffi';

import 'package:ffi/ffi.dart';

base class PitchResult extends Struct {
  @Double()
  external double pitch;
  
  @Double()
  external double duration;
  
  external Pointer<Utf8> note;
  
  @Double()
  external double startTime;

  
  @Double()
  external double amplitude;
}