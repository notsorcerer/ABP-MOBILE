import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../admin/dashboard_screen.dart';
import '../auth/login_screen.dart';
import '../orders/order_list_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (!authProvider.isLoggedIn) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 64,
                    color: AppTheme.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Anda belum masuk',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text('Masuk / Daftar'),
                  ),
                ],
              ),
            );
          }

          final user = authProvider.user!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppTheme.primary,
                        child: Text(
                          user.name[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 32,
                            color: AppTheme.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          color: AppTheme.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (user.isAdmin)
                Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.admin_panel_settings, color: AppTheme.secondary),
                      title: const Text('Admin Panel'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AdminDashboardScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 0),
                  ],
                ),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.receipt_long, color: AppTheme.primary),
                      title: const Text('Pesanan Saya'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const OrderListScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 0),
                    ListTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title: const Text(
                        'Keluar',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Konfirmasi'),
                            content:
                                const Text('Apakah Anda yakin ingin keluar?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('Keluar'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await authProvider.logout();
                          if (context.mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
