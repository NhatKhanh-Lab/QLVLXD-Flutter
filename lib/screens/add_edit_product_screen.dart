import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../utils/currency_formatter.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _lowStockThresholdController = TextEditingController();
  final _uuid = const Uuid();

  String _selectedCategory = 'Xi măng';
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  final List<String> _categories = [
    'Xi măng',
    'Sắt thép',
    'Gạch',
    'Sơn',
    'Gỗ',
    'Ống nước',
    'Dây điện',
    'Khác',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      // Format giá với dấu phân cách hàng nghìn
      final formatter = NumberFormat.decimalPattern('vi_VN');
      _priceController.text = formatter.format(widget.product!.price.toInt());
      _quantityController.text = widget.product!.quantity.toString();
      _unitController.text = widget.product!.unit;
      _descriptionController.text = widget.product!.description ?? '';
      _lowStockThresholdController.text =
          widget.product!.lowStockThreshold.toString();
      _selectedCategory = widget.product!.category;
      _imagePath = widget.product!.imagePath;
    } else {
      _lowStockThresholdController.text = '10';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _descriptionController.dispose();
    _lowStockThresholdController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi chọn ảnh: $e')),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi chụp ảnh: $e')),
        );
      }
    }
  }

  Future<void> _saveProduct() async {
    print('DEBUG: Save button pressed');
    if (!_formKey.currentState!.validate()) {
      print('DEBUG: Form validation failed');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng kiểm tra lại các trường bắt buộc'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('DEBUG: Form validation passed');
    
    // Hiển thị loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Đang lưu...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final now = DateTime.now();
      // Loại bỏ dấu phân cách hàng nghìn trước khi parse
      final priceText = _priceController.text.replaceAll(RegExp(r'[^\d]'), '');
      final product = Product(
        id: widget.product?.id ?? _uuid.v4(),
        name: _nameController.text.trim(),
        category: _selectedCategory,
        price: double.parse(priceText),
        quantity: int.parse(_quantityController.text),
        unit: _unitController.text.trim(),
        imagePath: _imagePath,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        lowStockThreshold:
            int.parse(_lowStockThresholdController.text),
        createdAt: widget.product?.createdAt ?? now,
        updatedAt: now,
      );

      final provider = Provider.of<ProductProvider>(context, listen: false);
      
      if (widget.product == null) {
        await provider.addProduct(product);
        print('DEBUG: Product added successfully');
      } else {
        await provider.updateProduct(product);
        print('DEBUG: Product updated successfully');
      }

      if (mounted) {
        // Đóng loading dialog
        Navigator.pop(context);
        // Đóng form
        Navigator.pop(context);
        
        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(widget.product == null 
                    ? 'Đã thêm sản phẩm thành công' 
                    : 'Đã cập nhật sản phẩm thành công'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('DEBUG: Error saving product: $e');
      if (mounted) {
        // Đóng loading dialog
        Navigator.pop(context);
        
        // Hiển thị thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Lỗi: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Thêm sản phẩm' : 'Sửa sản phẩm'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 100, // Thêm padding dưới để nút không bị che
          ),
          children: [
            // Image
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.photo_library),
                          title: const Text('Chọn từ thư viện'),
                          onTap: () {
                            Navigator.pop(context);
                            _pickImage();
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.camera_alt),
                          title: const Text('Chụp ảnh'),
                          onTap: () {
                            Navigator.pop(context);
                            _takePhoto();
                          },
                        ),
                        if (_imagePath != null)
                          ListTile(
                            leading: const Icon(Icons.delete),
                            title: const Text('Xóa ảnh'),
                            onTap: () {
                              Navigator.pop(context);
                              setState(() {
                                _imagePath = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_imagePath!),
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, size: 50),
                            SizedBox(height: 8),
                            Text('Chạm để thêm ảnh'),
                          ],
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên sản phẩm *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên sản phẩm';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Danh mục *',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // Price
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Giá *',
                border: const OutlineInputBorder(),
                hintText: '1.000.000',
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(
                    'VND',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyInputFormatter()],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập giá';
                }
                final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
                if (double.tryParse(cleanValue) == null || double.parse(cleanValue) < 0) {
                  return 'Giá không hợp lệ';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Quantity
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Số lượng *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập số lượng';
                }
                if (int.tryParse(value) == null || int.parse(value) < 0) {
                  return 'Số lượng không hợp lệ';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Unit
            TextFormField(
              controller: _unitController,
              decoration: InputDecoration(
                labelText: 'Đơn vị *',
                border: const OutlineInputBorder(),
                hintText: 'kg, m, thùng, ...',
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(
                    'kg',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập đơn vị';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Low Stock Threshold
            TextFormField(
              controller: _lowStockThresholdController,
              decoration: const InputDecoration(
                labelText: 'Ngưỡng cảnh báo tồn kho',
                border: OutlineInputBorder(),
                helperText: 'Cảnh báo khi số lượng <= giá trị này',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập ngưỡng cảnh báo';
                }
                if (int.tryParse(value) == null || int.parse(value) < 0) {
                  return 'Giá trị không hợp lệ';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _saveProduct,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                widget.product == null ? 'Thêm sản phẩm' : 'Cập nhật',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

