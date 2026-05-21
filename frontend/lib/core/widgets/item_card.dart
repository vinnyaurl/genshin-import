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
      if (count % 3 == 0 && i != 0) {
        result = ',' + result;
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = stock <= 0;

    Widget imageWidget = Image.network(
      image,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const Center(
        child: Icon(Icons.broken_image_outlined, color: Colors.black26, size: 40),
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onCardTap, 
                behavior: HitTestBehavior.opaque,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        color: const Color(0xFFF8FAFC), 
                        child: imageWidget, 
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(type, style: const TextStyle(color: Color(0xFFA0AEC0), fontSize: 13)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Item Left:', 
                                style: TextStyle(
                                  color: isOutOfStock ? AppColors.errorRed : AppColors.primaryAmberDark, 
                                  fontSize: 13, 
                                  fontWeight: FontWeight.w600
                                ),
                              ),
                              Text(
                                stock.toString(),
                                style: TextStyle(
                                  color: isOutOfStock ? AppColors.errorRed : AppColors.primaryAmberDark, 
                                  fontSize: 13, 
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            AbsorbPointer(
              absorbing: isOutOfStock, 
              child: GestureDetector(
                onTap: onBuyTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isOutOfStock 
                        ? null 
                        : const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [AppColors.primaryAmberLight, AppColors.primaryAmberDark],
                          ),
                    color: isOutOfStock ? AppColors.errorRed : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!isOutOfStock) ...[
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), shape: BoxShape.circle),
                          child: const Icon(Icons.attach_money, color: Colors.white, size: 14),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        isOutOfStock ? 'out of stock' : _formatPrice(price), // Memanggil fungsi non-regex
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
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