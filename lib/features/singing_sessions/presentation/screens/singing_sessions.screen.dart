import 'package:flutter/material.dart';
import 'package:singing_app/features/singing_sessions/domain/singing_session.model.dart';
import 'package:singing_app/features/singing_sessions/presentation/widgets/singing_session_card.widget.dart';

class SingingSessionsScreen extends StatelessWidget {
  const SingingSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(20),
          physics: BouncingScrollPhysics(),
          children: [
            SizedBox(
              height: 20,
            ),
            ...List.generate(
              singingSessions.length,
              (int index) => Padding(
                padding: const EdgeInsets.only(
                  bottom: 20,
                ),
                child: SingingSessionCard(
                  singingSession: singingSessions[index],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<SingingSession> get singingSessions => [
        SingingSession(
          id: '1',
          name: 'Health Check',
          audioPath: 'assets/vocals/HEALTH_CHECK.mp3',
        ),
        SingingSession(
          id: '2',
          name: 'Mia Mia Mia',
          audioPath: 'assets/vocals/MIA_MIA_MIA.mp3',
        ),
        SingingSession(
          id: '3',
          name: 'Sustained Descending',
          audioPath: 'assets/vocals/SUSTAINED_DESCENDING.mp3',
        ),
        SingingSession(
          id: '4',
          name: 'Yawny Vowels',
          audioPath: 'assets/vocals/YAWNY_VOWELS.mp3',
        ),
      ];
}
