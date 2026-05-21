import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isAdmin;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: Colors.white,
          iconSize: 28,
          selectedFontSize: 13,
          unselectedFontSize: 13,
          
          selectedItemColor: AppColors.primaryAmberLight,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          
          unselectedItemColor: const Color(0xFFCBD5E1),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          showUnselectedLabels: true,
          
          type: BottomNavigationBarType.fixed,
          elevation: 0, 
          
          items: [
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 6.0, top: 8.0),
                child: Icon(isAdmin ? Icons.warehouse_outlined : Icons.shopping_bag_outlined),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.only(bottom: 6.0, top: 8.0),
                child: Icon(isAdmin ? Icons.warehouse : Icons.shopping_bag),
              ),
              label: isAdmin ? 'Admin' : 'Shop',
            ),
            
            BottomNavigationBarItem(
              icon: const Padding(
                padding: EdgeInsets.only(bottom: 6.0, top: 8.0),
                child: Icon(Icons.person_outline),
              ),
              activeIcon: const Padding(
                padding: EdgeInsets.only(bottom: 6.0, top: 8.0),
                child: Icon(Icons.person),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}