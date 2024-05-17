import 'package:flutter/widgets.dart';

class ReminderColor extends StatelessWidget {
  const ReminderColor({
    super.key,
    required this.color,
    required this.title,
    });

  final Color color;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 16,
      width: 24,
      child: Expanded(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                color: color,
              ),
            ),
            const SizedBox(width: 8,),
            Text(title),
          ],
        )
      ),
    );
  }
}