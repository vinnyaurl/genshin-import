import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ItemCard extends StatelessWidget {
  final int id;
  final String name;
  final String type;
  final int stock;
  final int price;
  final String image;
  final VoidCallback onCardTap;
  final VoidCallback onBuyTap;

  const ItemCard({
    super.key,
    required this.id,
    required this.name,
    required this.type,
    required this.stock,
    required this.price,
    required this.image,
    required this.onCardTap,
    required this.onBuyTap,
  });

  String _formatPrice(int value) {
    String str = value.toString();
    String result = '';
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      count++;
      result = str[i] + result;
      if (count % 3 == 0 && i != 0) result = ',$result';
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = stock <= 0;

    Widget imageWidget = AspectRatio(
      aspectRatio: 1 / 1, 
      child: Container(
        color: const Color(0xFFF8FAFC),
        padding: const EdgeInsets.all(8),
        child: Image.network(
          image,
          fit: BoxFit.contain, 
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined, color: Colors.black26, size: 40),
        ),
      ),
    );

    if (isOutOfStock) {
      imageWidget = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.21, 0.72, 0.07, 0, 0, 0.21, 0.72, 0.07, 0, 0, 0.21, 0.72, 0.07, 0, 0, 0, 0, 0, 1, 0,
        ]),
        child: imageWidget,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: onCardTap,
              behavior: HitTestBehavior.opaque,
              child: Column(
                children: [
                  imageWidget,
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(type, style: const TextStyle(color: Color(0xFFA0AEC0), fontSize: 12)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Stock:', style: TextStyle(fontSize: 11)),
                            Text(stock.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isOutOfStock ? AppColors.errorRed : AppColors.primaryAmberDark)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Tombol Buy
            AbsorbPointer(
              absorbing: isOutOfStock,
              child: GestureDetector(
                onTap: onBuyTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isOutOfStock ? AppColors.errorRed : AppColors.primaryAmberDark,
                  ),
                  child: Center(
                    child: Text(
                      isOutOfStock ? 'OUT OF STOCK' : _formatPrice(price),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}