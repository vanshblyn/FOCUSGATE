import 'package:flutter/material.dart';
import '../models/question_model.dart';

class McqGatekeeperScreen extends StatefulWidget {
  final VoidCallback onUnlockSuccess;

  const McqGatekeeperScreen({super.key, required this.onUnlockSuccess});

  @override
  State<McqGatekeeperScreen> createState() => _McqGatekeeperScreenState();
}

class _McqGatekeeperScreenState extends State<McqGatekeeperScreen> {
  int currentQuestionIndex = 0;
  int completedRequired = 0;
  final int totalRequired = 3;

  bool isShowingReinforcement = false;
  bool isShowingSolution = false;
  int? selectedOption;
  String statusMessage = 'Solve 3 questions to unlock entertainment apps';

  QuizItem get currentItem {
    final pair = sampleQuestionBank[currentQuestionIndex % sampleQuestionBank.length];
    return isShowingReinforcement ? pair.reinforcement : pair.primary;
  }

  void handleAnswerSelect(int index) {
    setState(() {
      selectedOption = index;
    });

    if (index == currentItem.correctIndex) {
      setState(() {
        completedRequired++;
        isShowingSolution = false;
        selectedOption = null;
        if (isShowingReinforcement) {
          isShowingReinforcement = false;
          currentQuestionIndex++;
          statusMessage = 'Concept Mastered! 🎯 Move to next question.';
        } else {
          currentQuestionIndex++;
          statusMessage = 'Correct answer! Keep going.';
        }
      });

      if (completedRequired >= totalRequired) {
        widget.onUnlockSuccess();
      }
    } else {
      setState(() {
        isShowingSolution = true;
        statusMessage = 'Incorrect! Review the formula & try twin question.';
      });
    }
  }

  void proceedToReinforcementQuestion() {
    setState(() {
      isShowingSolution = false;
      isShowingReinforcement = true;
      selectedOption = null;
      statusMessage = 'Similar Question: Apply the concept now!';
    });
  }

  @override
  Widget build(BuildContext context) {
    final pair = sampleQuestionBank[currentQuestionIndex % sampleQuestionBank.length];

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'FocusGate Shield',
                    style: TextStyle(color: Color(0xFF00F2FE), fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB800).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Target: $completedRequired / $totalRequired',
                      style: const TextStyle(color: Color(0xFFFFB800), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Topic: ${pair.topic} • ${pair.formula}',
                      style: const TextStyle(color: Color(0xFF00F2FE), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      currentItem.question,
                      style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ...List.generate(currentItem.options.length, (idx) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      backgroundColor: selectedOption == idx
                          ? (idx == currentItem.correctIndex ? Colors.green.shade800 : Colors.red.shade800)
                          : Colors.white.withOpacity(0.08),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isShowingSolution ? null : () => handleAnswerSelect(idx),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${String.fromCharCode(65 + idx)}.  ${currentItem.options[idx]}',
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
              if (isShowingSolution)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161F30),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFB800)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '💡 Concept Breakdown & Solution:',
                        style: TextStyle(color: Color(0xFFFFB800), fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentItem.explanation,
                        style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00F2FE)),
                          onPressed: proceedToReinforcementQuestion,
                          child: const Text('Try Similar Question Now', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
