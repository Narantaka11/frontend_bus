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
    _loadBuses();
  }

  void _loadBuses() {
    _busesFuture = AdminService.getBuses();
  }

  void _refresh() {
    setState(() {
      _loadBuses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Bus')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _busesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: AppColors.error),
              ),
            );
          }

          final buses = snapshot.data ?? [];
          if (buses.isEmpty) {
            return const Center(child: Text('Tidak ada data bus.'));
          }

          return RefreshIndicator(
            onRefresh: () async => _refresh(),
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
                      child: Icon(Icons.directions_bus,
                          color: AppColors.orangeSeat),
                    ),
                    title: Text(
                      bus['name'] ?? '-',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${bus['plate']} • ${bus['totalSeat']} Kursi',
                      style: AppTextStyles.caption,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit,
                              color: AppColors.textGray),
                          onPressed: () => _openForm(bus: bus),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: AppColors.error),
                          onPressed: () => _confirmDelete(bus['id']),
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
        child: const Icon(Icons.add, color: AppColors.white),
        onPressed: () => _openForm(),
      ),
    );
  }

  // ================= FORM ADD / EDIT (UI FIX ONLY) =================

  void _openForm({Map<String, dynamic>? bus}) {
    final nameController =
        TextEditingController(text: bus != null ? bus['name'] : '');
    final plateController =
        TextEditingController(text: bus != null ? bus['plate'] : '');
    final seatController =
        TextEditingController(text: bus != null ? '${bus['totalSeat']}' : '');

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
                    bus == null ? 'Tambah Bus' : 'Edit Bus',
                    style: AppTextStyles.h3,
                  ),
                ),
                const SizedBox(height: 24),

                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Bus',
                    hintText: 'Contoh: Djawa Bus - Eksekutif',
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: plateController,
                  decoration: const InputDecoration(
                    labelText: 'Plat Nomor',
                    hintText: 'Contoh: B 1234 PK',
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: seatController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah Kursi',
                    hintText: 'Contoh: 32',
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
                      Navigator.pop(context);

                      if (bus == null) {
                        await AdminService.createBus(
                          name: nameController.text,
                          plate: plateController.text,
                          totalSeat: int.parse(seatController.text),
                        );
                      } else {
                        await AdminService.updateBus(
                          bus['id'],
                          name: nameController.text,
                          plate: plateController.text,
                          totalSeat: int.parse(seatController.text),
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

  // ================= DELETE =================

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Bus'),
        content: const Text('Yakin ingin menghapus bus ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AdminService.deleteBus(id);
              _refresh();
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
