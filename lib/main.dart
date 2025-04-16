


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:singing_app/core/bloc/pitch_cubit.dart';
import 'package:singing_app/core/services/requestPermissions.service.dart';
import 'package:singing_app/ui/audio/convertAudio.page.dart';

Future<void> main() async {
     // Paso 1: Inicializar binding
  WidgetsFlutterBinding.ensureInitialized();
  
  // Paso 2: Luego solicitar permisosp
  await requestPermissions();
  runApp(
     BlocProvider(
      create: (context) => PitchCubit(),
      child:  MyAppAudio(),
    ),
    
    
   );
}

class MyAppAudio extends StatelessWidget {
  const MyAppAudio({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
    home: ConvertAudioPage(),
      );
  }
}

























// Future<void> main() async {
//    // Aseguramos que el binding esté inicializado
//   WidgetsFlutterBinding.ensureInitialized();
//   await requestPermissions();
//   setupDependencies();
//   runApp(SingingApp());
// }



// Future<void> main() async {
//   //    // Aseguramos que el binding esté inicializado
//   WidgetsFlutterBinding.ensureInitialized();
//   await requestPermissions();
//   setupDependencies();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Afinador en Tiempo Real',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: HomeScreen(),  // Define HomeScreen como la pantalla inicial
//     );
//   }
// }

/************************************************************************************************* */

