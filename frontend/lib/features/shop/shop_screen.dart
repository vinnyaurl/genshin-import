import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/bottom_navbar.dart';
import 'package:frontend/core/widgets/item_card.dart';
import 'package:frontend/features/profile/profile_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import 'item_detail_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int _selectedIndex = 0; 
  List<dynamic> _items = [];
  bool _isLoading = true;
  String _errorMessage = '';

  String _token = '';
  String _username = 'Traveler';
  bool _isAdmin = false;
  int _balance = 9999999; 

  final Map<int, int> _purchaseCounts = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token') ?? '';
      _username = prefs.getString('username') ?? 'Traveler';
      _isAdmin = prefs.getString('role') == 'admin';
    });
    
    _fetchWeapons();
  }

  String _formatCurrency(int value) {
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

  Future<void> _fetchWeapons() async {
    if (_token.isEmpty) return; 

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final url = Uri.parse('http://10.0.2.2:3000/weapons'); 
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _items = data; 
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load items (Error ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Cannot connect to server.';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleDirectBuy(int id, String name) async {
    try {
      final url = Uri.parse('http://10.0.2.2:3000/weapons/$id/buy');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'quantity': 1
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          setState(() {
            _purchaseCounts[id] = (_purchaseCounts[id] ?? 0) + 1;
            _balance = data['remaining_balance'] ?? _balance;
          });

          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully purchased ${_purchaseCounts[id]} x $name!'),
              backgroundColor: AppColors.successGreen,
            ),
          );
          _fetchWeapons(); 
        }
      } else {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightBlue, 
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        isAdmin: _isAdmin, 
        onTap: (index) {
          if (index == 1) { 
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            ).then((_) {
              _fetchWeapons();
            });
          }
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Genshin Import', style: AppTheme.headerStyle.copyWith(fontSize: 24, color: AppColors.primaryAmberDark)),
                      const SizedBox(height: 4),
                      Text('Welcome, $_username!', style: const TextStyle(color: Color(0xFFA0AEC0), fontSize: 13)),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.monetization_on, color: AppColors.primaryAmberLight, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        _formatCurrency(_balance),
                        style: TextStyle(color: AppColors.primaryAmberLight.withValues(alpha: 0.9), fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryAmberDark,
                onRefresh: _fetchWeapons,
                child: _buildBodyContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primaryAmberDark));
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.errorRed, size: 60),
            const SizedBox(height: 16),
            Text(_errorMessage, style: const TextStyle(color: AppColors.errorRed)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchWeapons,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryAmberDark),
              child: const Text('Try Again', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      );
    }

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.65,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        final int itemId = item['id'] ?? 0;
        final String itemName = item['name'] ?? 'Unknown Item';

        return ItemCard(
          id: itemId,
          name: itemName,
          type: item['type'] ?? 'Unknown',
          stock: item['stock'] ?? 0,
          price: item['price'] ?? 0,
          image: item['image'] ?? 'https://via.placeholder.com/150',
          onCardTap: () async {
            final bool? isBought = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ItemDetailScreen(item: item)),
            );

            if (isBought == true) {
              setState(() {
                _purchaseCounts[itemId] = (_purchaseCounts[itemId] ?? 0) + 1;
              });
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Successfully purchased ${_purchaseCounts[itemId]} x $itemName!'),
                  backgroundColor: AppColors.successGreen,
                ),
              );
              _fetchWeapons();
            }
          },
          onBuyTap: () => _handleDirectBuy(itemId, itemName),
        );
      },
    );
  }
}