import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../providers/admin_provider.dart';

class AdminProductFormScreen extends StatefulWidget {
  final Product? product;

  const AdminProductFormScreen({super.key, this.product});

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  List<Category> _categories = [];
  int? _selectedCategoryId;
  bool _isBestSeller = false;
  bool _isNewArrival = false;
  File? _imageFile;
  String? _existingImageUrl;
  bool _isLoading = false;

  final _picker = ImagePicker();
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.product != null;

    if (_isEdit) {
      final p = widget.product!;
      _nameController.text = p.name;
      _descriptionController.text = p.description;
      _priceController.text = p.price.toStringAsFixed(0);
      _selectedCategoryId = p.category.id;
      _isBestSeller = p.isBestSeller;
      _isNewArrival = p.isNewArrival;
      _existingImageUrl = p.imageUrl;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = context.read<AdminProvider>();
      adminProvider.loadCategories().then((_) {
        if (mounted) {
          setState(() {
            _categories = adminProvider.categories;
            if (!_isEdit && _categories.isNotEmpty) {
              _selectedCategoryId ??= _categories.first.id;
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file != null) {
      setState(() => _imageFile = File(file.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori')),
      );
      return;
    }
    if (!_isEdit && _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih gambar produk')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final adminProvider = context.read<AdminProvider>();
    final price = double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0;

    bool success;
    if (_isEdit) {
      success = await adminProvider.updateProduct(
        widget.product!.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: price,
        categoryId: _selectedCategoryId!,
        imagePath: _imageFile?.path,
        isBestSeller: _isBestSeller,
        isNewArrival: _isNewArrival,
      );
    } else {
      success = await adminProvider.createProduct(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: price,
        categoryId: _selectedCategoryId!,
        imagePath: _imageFile?.path,
        isBestSeller: _isBestSeller,
        isNewArrival: _isNewArrival,
      );
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEdit ? 'Produk berhasil diperbarui' : 'Produk berhasil ditambahkan')),
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Produk' : 'Tambah Produk'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.lightGrey),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_imageFile!, fit: BoxFit.cover, width: double.infinity),
                      )
                    : _existingImageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(_existingImageUrl!, fit: BoxFit.cover, width: double.infinity,
                              errorBuilder: (context, error, stackTrace) => _imagePlaceholder()),
                          )
                        : _imagePlaceholder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Produk'),
              validator: (v) => v?.trim().isEmpty == true ? 'Nama tidak boleh kosong' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
              maxLines: 4,
              validator: (v) => v?.trim().isEmpty == true ? 'Deskripsi tidak boleh kosong' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Harga',
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v?.trim().isEmpty == true) return 'Harga tidak boleh kosong';
                final price = double.tryParse(v!.replaceAll(',', '.'));
                if (price == null || price < 0) return 'Harga tidak valid';
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(labelText: 'Kategori'),
              items: _categories.map((cat) => DropdownMenuItem(
                value: cat.id,
                child: Text(cat.name),
              )).toList(),
              onChanged: (v) => setState(() => _selectedCategoryId = v),
              validator: (v) => v == null ? 'Pilih kategori' : null,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Best Seller'),
              value: _isBestSeller,
              onChanged: (v) => setState(() => _isBestSeller = v),
              activeTrackColor: AppTheme.primary.withValues(alpha: 0.4),
              activeThumbColor: AppTheme.primary,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('New Arrival'),
              value: _isNewArrival,
              onChanged: (v) => setState(() => _isNewArrival = v),
              activeTrackColor: AppTheme.primary.withValues(alpha: 0.4),
              activeThumbColor: AppTheme.primary,
              contentPadding: EdgeInsets.zero,
            ),
            if (context.watch<AdminProvider>().error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  context.read<AdminProvider>().error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(_isEdit ? 'Simpan Perubahan' : 'Tambah Produk'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined, size: 48, color: AppTheme.grey),
          const SizedBox(height: 8),
          Text('Tap untuk pilih gambar', style: TextStyle(color: AppTheme.grey)),
        ],
      ),
    );
  }
}
