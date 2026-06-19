import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/category.dart';
import '../../providers/admin_provider.dart';

class AdminCategoryFormScreen extends StatefulWidget {
  final Category? category;

  const AdminCategoryFormScreen({super.key, this.category});

  @override
  State<AdminCategoryFormScreen> createState() => _AdminCategoryFormScreenState();
}

class _AdminCategoryFormScreenState extends State<AdminCategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isEdit = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.category != null;
    if (_isEdit) {
      _nameController.text = widget.category!.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final adminProvider = context.read<AdminProvider>();

    bool success;
    if (_isEdit) {
      success = await adminProvider.updateCategory(widget.category!.id, _nameController.text.trim());
    } else {
      success = await adminProvider.createCategory(_nameController.text.trim());
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEdit ? 'Kategori berhasil diperbarui' : 'Kategori berhasil ditambahkan')),
      );
      Navigator.of(context).pop(true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(adminProvider.error ?? 'Gagal menyimpan kategori')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Kategori' : 'Tambah Kategori'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Kategori'),
              validator: (v) => v?.trim().isEmpty == true ? 'Nama tidak boleh kosong' : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(_isEdit ? 'Simpan Perubahan' : 'Tambah Kategori'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
