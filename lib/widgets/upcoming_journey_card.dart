import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class UpcomingJourneyCard extends StatelessWidget {
  final int index;
  final String busName;
  final String origin;
  final String destination;
  final String departureTime;

  const UpcomingJourneyCard({
    super.key,
    required this.index,
    required this.busName,
    required this.origin,
    required this.destination,
    required this.departureTime,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.orange200,
              child: Text(
                index.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(busName, style: AppTextStyles.h4),
                  const SizedBox(height: 4),
                  Text('Dari: $origin'),
                  Text('Ke: $destination'),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Berangkat'),
                Text(
                  departureTime,
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.brownFont,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
