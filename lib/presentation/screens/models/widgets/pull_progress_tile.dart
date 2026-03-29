import 'package:flutter/material.dart';

class PullProgressTile extends StatelessWidget {
  final double progress;
  final String info;

  const PullProgressTile({
    super.key,
    required this.progress,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(info),
        const SizedBox(height: 4),
        LinearProgressIndicator(value: progress),
      ],
    );
  }
}
