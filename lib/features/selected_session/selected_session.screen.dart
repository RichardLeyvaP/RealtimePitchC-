import 'dart:math';
import 'package:flutter/material.dart';
import 'package:singing_app/core/dependencies/dependencies.dart';
import 'package:singing_app/core/design_system/widgets/buttons/core_button.widget.dart';
import 'package:singing_app/core/navigation/services/navigation.service.dart';
import 'package:singing_app/features/selected_session/domain/models/tune_note.model.dart';
import 'package:singing_app/features/singing_sessions/domain/singing_session.model.dart';
import 'package:audioplayers/audioplayers.dart';

class SelectedSessionScreen extends StatefulWidget {
  const SelectedSessionScreen({
    required this.singingSession,
    super.key,
  });

  final SingingSession singingSession;

  @override
  PitchVisualizerScreenState createState() => PitchVisualizerScreenState();
}

class PitchVisualizerScreenState extends State<SelectedSessionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late AudioPlayer _audioPlayer; // Audio player instance
  final List<TuneNote> _notes = [];

  final double minPitch = 40;
  final double maxPitch = 80;
  double totalDuration = 0;

  double scaleFactor = 4; // Adjust this to increase/decrease width and speed

  @override
  void initState() {
    super.initState();

    // Initialize the audio player and play the MP3 file from a local path
    _audioPlayer = AudioPlayer();
    // For audioplayers v1.0+, use DeviceFileSource for local files:
    _audioPlayer.play(DeviceFileSource(widget.singingSession.audioPath));

    _generateNotes();

    if (_notes.isNotEmpty) {
      totalDuration =
          (_notes.last.startTime + _notes.last.duration) / scaleFactor;
    }

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (totalDuration * 1000).toInt()),
    )..forward();
  }

  void _generateNotes() {
    final random = Random();
    double currentTime = 0.0;

    for (int i = 0; i < 80; i++) {
      final duration = (random.nextDouble() * 2 + 3.0); // Between 3s and 5s
      final gap = random.nextDouble(); // Random gap

      _notes.add(TuneNote(
        pitch: random.nextDouble() * (maxPitch - minPitch) + minPitch,
        startTime: currentTime,
        duration: duration,
      ));

      currentTime += duration + gap;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose(); // Dispose of the audio player
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.height;
    final double screenHeight = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: UICoreButton(
        onPressed: getIt<AppNavigationService>().routeToSelectedSessionResults,
        child: RotatedBox(
          quarterTurns: 1,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: Size(screenWidth, screenHeight),
                painter: PitchVisualizerPainter(
                  notes: _notes,
                  elapsedTime: _controller.value * totalDuration,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  minPitch: minPitch,
                  maxPitch: maxPitch,
                  totalDuration: totalDuration,
                  scaleFactor: scaleFactor,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class PitchVisualizerPainter extends CustomPainter {
  final List<TuneNote> notes;
  final double elapsedTime;
  final double screenWidth;
  final double screenHeight;
  final double minPitch;
  final double maxPitch;
  final double totalDuration;
  final double scaleFactor;

  PitchVisualizerPainter({
    required this.notes,
    required this.elapsedTime,
    required this.screenWidth,
    required this.screenHeight,
    required this.minPitch,
    required this.maxPitch,
    required this.totalDuration,
    required this.scaleFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2);
    final Paint notePaint = Paint()..color = Colors.white;
    final Paint activeNotePaint = Paint()..color = Colors.greenAccent;

    // Draw vertical guide lines
    for (double i = 0; i < screenWidth; i += screenWidth / 10) {
      canvas.drawLine(Offset(i, 0), Offset(i, screenHeight), gridPaint);
    }

    // Dynamic scroll speed (pixels per second), scaled
    double scrollSpeed = (screenWidth / totalDuration) * scaleFactor;

    for (var note in notes) {
      // Compute x-position based on start time
      double xPos = screenWidth - (elapsedTime - note.startTime) * scrollSpeed;

      // Compute y-position based on pitch (low notes at bottom, high at top)
      double yPos = screenHeight -
          ((note.pitch - minPitch) / (maxPitch - minPitch)) * screenHeight;

      // Ensure note width dynamically adjusts with duration and scroll speed
      double noteWidth = note.duration * scrollSpeed;
      double noteHeight = 30; // Adjusted height as well

      if (xPos + noteWidth > 0 && xPos < screenWidth) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(xPos, yPos, noteWidth, noteHeight),
            const Radius.circular(10),
          ),
          note.startTime <= elapsedTime ? activeNotePaint : notePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
