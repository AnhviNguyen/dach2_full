import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/controllers/learning_provider.dart';
import 'package:koreanhwa_flutter/shared/widgets/lesson_card.dart';
import 'package:provider/provider.dart';


class LearningIntroScreen extends StatefulWidget {
  const LearningIntroScreen({Key? key}) : super(key: key);

  @override
  State<LearningIntroScreen> createState() => _LearningIntroScreenState();
}

class _LearningIntroScreenState extends State<LearningIntroScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LearningProvider>().initializeLessons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const SizedBox(),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '9:41',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                Icon(Icons.signal_cellular_4_bar, color: Colors.black, size: 18),
                SizedBox(width: 4),
                Icon(Icons.wifi, color: Colors.black, size: 18),
                SizedBox(width: 4),
                Icon(Icons.battery_full, color: Colors.black, size: 18),
              ],
            ),
          ],
        ),
      ),
      body: Consumer<LearningProvider>(
        builder: (context, provider, child) {
          if (provider.lessons.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.lessons.length,
                  itemBuilder: (context, index) {
                    return LessonCard(
                      lesson: provider.lessons[index],
                      onTap: () {
                        provider.startLesson(provider.lessons[index].id);
                        // Navigate to lesson screen
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
