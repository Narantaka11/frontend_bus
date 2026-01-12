import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import '../../core/service/admin_service.dart';
import '../../core/service/session_manager.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AdminUserScreen extends StatefulWidget {
  const AdminUserScreen({super.key});

  @override
  State<AdminUserScreen> createState() => _AdminUserScreenState();
}

class _AdminUserScreenState extends State<AdminUserScreen> {
  late Future<List<Map<String, dynamic>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _usersFuture = AdminService.getUsers();
  }

  Future<void> _refresh() async {
    setState(_load);
  }

  // ================= ACTION =================

  Future<void> _promote(String id) async {
    final token = await SessionManager.getToken();
    await http.put(
      Uri.parse('${ApiConfig.baseUrl}admin/users/$id/promote'),
      headers: {'Authorization': 'Bearer $token'},
    );
    _refresh();
  }

  Future<void> _demote(String id) async {
    final token = await SessionManager.getToken();
    await http.put(
      Uri.parse('${ApiConfig.baseUrl}admin/users/$id/demote'),
      headers: {'Authorization': 'Bearer $token'},
    );
    _refresh();
  }

  Future<void> _createUser() async {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String role = 'USER';

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama')),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Password')),
              const SizedBox(height: 8),
              DropdownButtonFormField(
                value: role,
                items: const [
                  DropdownMenuItem(value: 'USER', child: Text('USER')),
                  DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN')),
                ],
                onChanged: (v) => role = v.toString(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final token = await SessionManager.getToken();
              await http.post(
                Uri.parse('${ApiConfig.baseUrl}admin/users'),
                headers: {
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                },
                body: jsonEncode({
                  'name': nameCtrl.text,
                  'email': emailCtrl.text,
                  'password': passCtrl.text,
                  'role': role,
                }),
              );
              Navigator.pop(context);
              _refresh();
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Color _roleColor(String role) =>
      role == 'ADMIN' ? Colors.red : Colors.grey;

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Users'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.brownFont,
        onPressed: _createUser,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _usersFuture,
        builder: (context, s) {
          if (s.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = s.data ?? [];
          if (users.isEmpty) {
            return const Center(child: Text('Tidak ada data user'));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (_, i) {
                final u = users[i];
                final role = u['role'];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(u['name'], style: AppTextStyles.bodyMedium),
                    subtitle: Text(u['email']),
                    leading: Chip(
                      label: Text(role),
                      backgroundColor: _roleColor(role),
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'promote') _promote(u['id']);
                        if (v == 'demote') _demote(u['id']);
                      },
                      itemBuilder: (_) => [
                        if (role == 'USER')
                          const PopupMenuItem(
                            value: 'promote',
                            child: Text('Promote to Admin'),
                          ),
                        if (role == 'ADMIN')
                          const PopupMenuItem(
                            value: 'demote',
                            child: Text('Demote to User'),
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
    );
  }
}
