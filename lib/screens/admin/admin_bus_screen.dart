import 'package:flutter/material.dart';
import '../../core/service/admin_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AdminBusScreen extends StatefulWidget {
  const AdminBusScreen({super.key});

  @override
  State<AdminBusScreen> createState() => _AdminBusScreenState();
}

class _AdminBusScreenState extends State<AdminBusScreen> {
  late Future<List<Map<String, dynamic>>> _busesFuture;

  @override
  void initState() {
    super.initState();
    _busesFuture = AdminService.getBuses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Buses')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _busesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final buses = snapshot.data ?? [];
          if (buses.isEmpty) {
            return const Center(child: Text('Tidak ada data bus.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _busesFuture = AdminService.getBuses();
              });
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: buses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final bus = buses[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.orange100,
                      child: Icon(
                        Icons.directions_bus,
                        color: AppColors.orangeSeat,
                      ),
                    ),
                    title: Text(
                      bus['name'] ?? 'Unnamed Bus',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${bus['type']} • ${bus['totalSeat']} Kursi',
                      style: AppTextStyles.caption,
                    ),
                    trailing: const Icon(
                      Icons.edit,
                      size: 20,
                      color: AppColors.textGray,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.brownFont,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }
}
