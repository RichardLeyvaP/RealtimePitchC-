import 'package:flutter/material.dart';
import 'package:singing_app/core/dependencies/dependencies.dart';
import 'package:singing_app/core/design_system/widgets/buttons/core_button.widget.dart';
import 'package:singing_app/core/navigation/services/navigation.service.dart';
import 'package:singing_app/core/pitch/service/pitchDetectionService.dart';
import 'package:singing_app/features/singing_sessions/domain/singing_session.model.dart';

class SingingSessionCard extends StatelessWidget {
  const SingingSessionCard({
    required this.singingSession,
    super.key,
  });

  final SingingSession singingSession;

  @override
  Widget build(BuildContext context) {
    return UICoreButton(
      onPressed: () {
        extractPitchFromAudio('assets/vocals/HEALTH_CHECK.mp3');
        getIt<AppNavigationService>().routeToSelectedSession(
        singingSession,
      );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.teal.shade300,
              Colors.teal.shade400,
              Colors.teal.shade700,
              Colors.teal.shade800,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 70,
        ),
        child: Text(
          singingSession.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
