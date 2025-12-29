import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';
import 'package:intl/intl.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.decimalPattern('vi_VN');
    final isLowStock = product.isLowStock;
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Image Section ---
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.5,
                  child: _buildImage(product.imagePath),
                ),
                if (isLowStock)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Chip(
                      label: const Text('TỒN KHO THẤP'),
                      labelStyle: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      backgroundColor: theme.colorScheme.error,
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    ),
                  ),
              ],
            ),

            // --- Content Section ---
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.category,
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          '${currencyFormat.format(product.price)} VND',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'Tồn: ${product.quantity}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isLowStock ? theme.colorScheme.error : Colors.grey[700],
                          fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            // --- Actions Footer ---
            Container(
              color: Colors.grey[50],
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      onPressed: onEdit,
                      tooltip: 'Sửa',
                      visualDensity: VisualDensity.compact,
                      color: Colors.grey[700],
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      onPressed: onDelete,
                      tooltip: 'Xóa',
                      color: theme.colorScheme.error,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String? imagePath) {
    // ... (rest of the _buildImage method remains the same)
    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: Icon(Icons.inventory_2_outlined, size: 40, color: Colors.grey[400]),
      );
    }

    final isNetworkImage = imagePath.startsWith('http');

    if (isNetworkImage) {
      return CachedNetworkImage(
        imageUrl: imagePath,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          alignment: Alignment.center,
          child: Icon(Icons.error_outline, size: 40, color: Colors.grey[400]),
        ),
      );
    } else {
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            alignment: Alignment.center,
            child: Icon(Icons.error_outline, size: 40, color: Colors.grey[400]),
          );
        },
      );
    }
  }
}
