import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:singing_app/core/models/audioPitch.model.dart';

class PitchCubit extends Cubit<List<AudioPitch>> {
  PitchCubit() : super([]);

  
  void addPitch(AudioPitch pitch) {
    emit([...state, pitch]);
  }

  
  void addPitches(List<AudioPitch> newPitches) {
    emit([...state, ...newPitches]); 
  }
}

