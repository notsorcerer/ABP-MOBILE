import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/category.dart';
import '../../providers/admin_provider.dart';
import 'category_form_screen.dart';

class AdminCategoryListScreen extends StatefulWidget {
  const AdminCategoryListScreen({super.key});

  @override
  State<AdminCategoryListScreen> createState() => _AdminCategoryListScreenState();
}

class _AdminCategoryListScreenState extends State<AdminCategoryListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Kelola Kategori'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const AdminCategoryFormScreen()),
          );
          if (result == true && context.mounted) {
            context.read<AdminProvider>().loadCategories();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, _) {
          if (adminProvider.isCategoriesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (adminProvider.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined, size: 48, color: AppTheme.grey),
                  const SizedBox(height: 16),
                  Text('Belum ada kategori', style: TextStyle(color: AppTheme.grey)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => adminProvider.loadCategories(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: adminProvider.categories.length,
              itemBuilder: (context, index) {
                final category = adminProvider.categories[index];
                return _CategoryItem(
                  category: category,
                  onEdit: () async {
                    final result = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => AdminCategoryFormScreen(category: category),
                      ),
                    );
                    if (result == true && context.mounted) {
                      adminProvider.loadCategories();
                    }
                  },
                  onDelete: () => _deleteCategory(category),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _deleteCategory(Category category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text('Yakin ingin menghapus "${category.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final success = await context.read<AdminProvider>().deleteCategory(category.id);
      if (mounted) {
        if (success) {
          context.read<AdminProvider>().loadCategories();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kategori berhasil dihapus')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.read<AdminProvider>().error ?? 'Gagal menghapus kategori')),
          );
        }
      }
    }
  }
}

class _CategoryItem extends StatelessWidget {
  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryItem({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(Icons.folder_outlined, color: AppTheme.primary),
        title: Text(category.name),
        subtitle: Text('${category.productsCount} produk'),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
          onPressed: onDelete,
        ),
        onTap: onEdit,
      ),
    );
  }
}
