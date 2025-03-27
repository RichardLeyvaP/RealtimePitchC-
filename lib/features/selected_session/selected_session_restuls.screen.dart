import 'package:flutter/material.dart';
import 'package:singing_app/core/dependencies/dependencies.dart';
import 'package:singing_app/core/navigation/services/navigation.service.dart';

class SelectedSessionResultsScreen extends StatelessWidget {
  final int sessionNumber;
  final double scorePercentage;

  const SelectedSessionResultsScreen({
    super.key,
    required this.sessionNumber,
    required this.scorePercentage,
  });

  @override
  Widget build(BuildContext context) {
    int starCount = (scorePercentage / 20).ceil().clamp(1, 5);
    String feedbackMessage = _getFeedbackMessage(starCount);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '#$sessionNumber Session Completed',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${scorePercentage.toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => Icon(
                  Icons.star_rate_sharp,
                  color: index < starCount ? Colors.amber : Colors.grey,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                feedbackMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: getIt<AppNavigationService>().routeToSingingSessions,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFeedbackMessage(int stars) {
    switch (stars) {
      case 1:
        return 'You can do better! Try again.';
      case 2:
        return 'Not bad, but there is room for improvement.';
      case 3:
        return 'Good job! Keep practicing.';
      case 4:
        return 'Great work! You\'re getting better.';
      case 5:
        return 'Excellent! You nailed it!';
      default:
        return 'Keep going!';
    }
  }
}
