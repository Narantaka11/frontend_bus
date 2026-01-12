import 'package:flutter/material.dart';
import '../../core/service/admin_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AdminRouteScreen extends StatefulWidget {
  const AdminRouteScreen({super.key});

  @override
  State<AdminRouteScreen> createState() => _AdminRouteScreenState();
}

class _AdminRouteScreenState extends State<AdminRouteScreen> {
  late Future<List<Map<String, dynamic>>> _routesFuture;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  void _loadRoutes() {
    _routesFuture = AdminService.getRoutes();
  }

  Future<void> _refresh() async {
    setState(() => _loadRoutes());
  }

  // ===================== FORM ADD / EDIT (SAMA DENGAN BUS) =====================
  void _openForm({Map<String, dynamic>? route}) {
    final originCtrl =
        TextEditingController(text: route?['origin'] ?? '');
    final destCtrl =
        TextEditingController(text: route?['destination'] ?? '');
    final distCtrl = TextEditingController(
      text: route?['distanceKm']?.toString() ?? '150',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    route == null ? 'Tambah Route' : 'Edit Route',
                    style: AppTextStyles.h3,
                  ),
                ),
                const SizedBox(height: 24),

                TextField(
                  controller: originCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Origin',
                    hintText: 'Contoh: Jakarta',
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: destCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Destination',
                    hintText: 'Contoh: Bandung',
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: distCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Jarak (KM)',
                    hintText: 'Contoh: 150',
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brownFont,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final km = int.tryParse(distCtrl.text.trim());
                      if (originCtrl.text.isEmpty ||
                          destCtrl.text.isEmpty ||
                          km == null) {
                        return;
                      }

                      Navigator.pop(context);

                      if (route == null) {
                        await AdminService.createRoute(
                          originCtrl.text,
                          destCtrl.text,
                          km,
                        );
                      } else {
                        await AdminService.updateRoute(
                          route['id'].toString(),
                          originCtrl.text,
                          destCtrl.text,
                          km,
                        );
                      }

                      _refresh();
                    },
                    child: const Text(
                      'Simpan',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===================== DELETE =====================
  Future<void> _delete(String id) async {
    await AdminService.deleteRoute(id);
    _refresh();
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Routes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _routesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final routes = snapshot.data ?? [];

          if (routes.isEmpty) {
            return const Center(child: Text('Tidak ada data route'));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: routes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final r = routes[index];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.orange100,
                      child: Icon(Icons.place,
                          color: AppColors.orangeSeat),
                    ),
                    title: Text(
                      '${r['origin']} → ${r['destination']}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Jarak: ${r['distanceKm']} KM',
                      style: AppTextStyles.caption,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit,
                              color: Colors.orange),
                          onPressed: () => _openForm(route: r),
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _delete(r['id'].toString()),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.brownFont,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
