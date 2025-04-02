import 'dart:ffi';

base class PitchResult extends Struct {
  @Double()
  external double pitch;
  
  @Double()
  external double duration;
  
  external Pointer<Char> note; // Cambiado a Char
  
  @Double()
  external double startTime;
  
  @Double()
  external double amplitude;
}