import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_button.dart';

class ItemDetailScreen extends StatefulWidget {
  final Map<String, dynamic> item;

  const ItemDetailScreen({
    super.key,
    required this.item,
  });

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  bool _isLoading = false;

  String _formatPrice(int value) {
    String str = value.toString();
    String result = '';
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      count++;
      result = str[i] + result;
      if (count % 3 == 0 && i != 0) result = ',' + result;
    }
    return result;
  }

  Future<void> _handleBuyItem(int id) async {
    setState(() => _isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Authentication error. Please login again.'), backgroundColor: AppColors.errorRed),
          );
          setState(() => _isLoading = false);
        }
        return;
      }

      final url = Uri.parse('http://10.0.2.2:3000/weapons/$id/buy');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', 
        },
        body: jsonEncode({
          'quantity': 1 
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          Navigator.pop(context, true); 
        }
      } else {
        final data = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Failed to buy item'), backgroundColor: AppColors.errorRed),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Network error. Transaction failed.'), backgroundColor: AppColors.errorRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int id = widget.item['id'] ?? 0;
    final String name = widget.item['name'] ?? 'Unknown Item';
    final String type = widget.item['type'] ?? 'Unknown';
    final int stock = widget.item['stock'] ?? 0;
    final int price = widget.item['price'] ?? 0;
    final String description = widget.item['description'] ?? 'No description available for this item.';
    final String image = widget.item['image'] ?? 'https://via.placeholder.com/400';

    final bool isOutOfStock = stock <= 0;

    Widget imageWidget = Image.network(
      image,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const Center(
        child: Icon(Icons.broken_image_outlined, color: Colors.black26, size: 60),
      ),
    );

    if (isOutOfStock) {
      imageWidget = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0,      0,      0,      1, 0,
        ]),
        child: imageWidget,
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32), 
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Price', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isOutOfStock ? Colors.grey.shade200 : AppColors.primaryAmberLight.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.attach_money, color: isOutOfStock ? Colors.grey : AppColors.primaryAmberDark, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatPrice(price),
                      style: TextStyle(
                        color: isOutOfStock ? Colors.grey : AppColors.primaryAmberLight,
                        fontWeight: FontWeight.bold,
                        fontSize: 28, 
                      ),
                    ),
                  ],
                ),
              ],
            ),
            isOutOfStock 
              ? Container(
                  width: 140, height: 50,
                  decoration: BoxDecoration(color: AppColors.errorRed, borderRadius: BorderRadius.circular(25)),
                  child: const Center(child: Text('Out of Stock', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                )
              : CustomButton(
                  text: 'Buy',
                  width: 140,
                  isLoading: _isLoading,
                  onPressed: () => _handleBuyItem(id),
                ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4, 
            child: Stack(
              children: [
                Container(
                  width: double.infinity, color: const Color(0xFFF8FAFC), 
                  child: SafeArea(child: Padding(padding: const EdgeInsets.all(32.0), child: imageWidget)),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16, left: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context), 
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(color: AppColors.primaryAmberLight, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 5, 
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(name, style: AppTheme.headerStyle.copyWith(fontSize: 28, color: AppColors.textPrimary))),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('In Stock', style: TextStyle(color: Color(0xFFA0AEC0), fontSize: 13)),
                            Text(
                              stock.toString(),
                              style: TextStyle(color: isOutOfStock ? AppColors.errorRed : AppColors.successGreen, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(type, style: const TextStyle(color: AppColors.primaryAmberDark, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 32),
                    const Text('Description', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    Text('"$description"', style: const TextStyle(color: Color(0xFFA0AEC0), fontStyle: FontStyle.italic, fontSize: 14, height: 1.5)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}