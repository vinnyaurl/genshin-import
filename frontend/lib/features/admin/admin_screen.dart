import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/bottom_navbar.dart';
import 'package:frontend/core/widgets/custom_button.dart';
import 'package:frontend/features/profile/profile_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _currentIndex = 0;
  
  List<dynamic> weapons = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String _token = '';

  final nameController = TextEditingController();
  final descController = TextEditingController();
  final imageController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  String selectedType = 'Sword';

  final List<String> weaponTypes = [
    'Sword', 'Bow', 'Catalyst', 'Polearm', 'Claymore'
  ];

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchWeapons();
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    imageController.dispose();
    priceController.dispose();
    stockController.dispose();
    super.dispose();
  }

  Future<void> _loadTokenAndFetchWeapons() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token') ?? '';
    });
    _fetchWeapons();
  }

  Future<void> _fetchWeapons() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/weapons'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          weapons = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        _showSnack('Failed to load weapons', isError: true);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showSnack('Network error. Cannot connect to server.', isError: true);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _insertWeapon() async {
    final error = _validateInputs();
    if (error != null) { _showSnack(error, isError: true); return; }

    setState(() => _isSubmitting = true);
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/weapons'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token'
        },
        body: jsonEncode({
          'name': nameController.text.trim(),
          'type': selectedType,
          'description': descController.text.trim(),
          'stock': int.parse(stockController.text),
          'price': double.parse(priceController.text).toInt(), // Backend butuh integer
          'image': imageController.text.trim(),
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showSnack('Weapon added successfully!');
        _fetchWeapons(); 
      } else {
        final data = jsonDecode(response.body);
        _showSnack(data['message'] ?? 'Failed to add weapon', isError: true);
      }
    } catch (e) {
      _showSnack('Network error.', isError: true);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _updateWeapon(int id) async {
    final error = _validateInputs();
    if (error != null) { _showSnack(error, isError: true); return; }

    setState(() => _isSubmitting = true);
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:3000/weapons/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token'
        },
        body: jsonEncode({
          'name': nameController.text.trim(),
          'type': selectedType,
          'description': descController.text.trim(),
          'stock': int.parse(stockController.text),
          'price': double.parse(priceController.text).toInt(),
          'image': imageController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        _showSnack('Weapon updated successfully!');
        _fetchWeapons(); 
      } else {
        final data = jsonDecode(response.body);
        _showSnack(data['message'] ?? 'Failed to update weapon', isError: true);
      }
    } catch (e) {
      _showSnack('Network error.', isError: true);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _deleteWeapon(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Weapon', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete this weapon?', style: GoogleFonts.lora(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: GoogleFonts.lora(color: AppColors.textSecondary))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete', style: GoogleFonts.lora(color: AppColors.errorRed))),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:3000/weapons/$id'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        _showSnack('Weapon deleted!');
        _fetchWeapons();
      } else {
        _showSnack('Failed to delete weapon', isError: true);
      }
    } catch (e) {
      _showSnack('Network error.', isError: true);
    }
  }

  Future<void> _adjustStock(int index, int delta) async {
    final weapon = weapons[index];
    final int newStock = (weapon['stock'] ?? 0) + delta;
    if (newStock < 0) return;

    setState(() {
      weapons[index]['stock'] = newStock;
    });

    try {
      await http.put(
        Uri.parse('http://10.0.2.2:3000/weapons/${weapon['id']}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token'
        },
        body: jsonEncode({
          'name': weapon['name'],
          'type': weapon['type'],
          'description': weapon['description'] ?? '',
          'stock': newStock,
          'price': weapon['price'],
          'image': weapon['image'],
        }),
      );
    } catch (e) {
      _showSnack('Sync error. Refreshing data...', isError: true);
      _fetchWeapons(); 
    }
  }

  void _clearControllers() {
    nameController.clear();
    descController.clear();
    imageController.clear();
    priceController.clear();
    stockController.clear();
    setState(() => selectedType = 'Sword');
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.lora()),
        backgroundColor: isError ? AppColors.errorRed : AppColors.primaryAmberDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String? _validateInputs() {
    if (nameController.text.trim().length < 3) return 'Name must be at least 3 characters';
    if (priceController.text.isEmpty || double.tryParse(priceController.text) == null) return 'Price must be a valid number';
    if (stockController.text.isEmpty || int.tryParse(stockController.text) == null) return 'Stock must be a valid number';
    return null;
  }

  void _showInsertModal() {
    _clearControllers();
    _openModal(title: 'Forge New Item', buttonLabel: 'Insert', onSubmit: _insertWeapon);
  }

  void _showEditModal(dynamic weapon) {
    nameController.text = weapon['name'] ?? '';
    descController.text = weapon['description'] ?? '';
    imageController.text = weapon['image'] ?? '';
    priceController.text = (weapon['price'] ?? 0).toString();
    stockController.text = (weapon['stock'] ?? 0).toString();
    setState(() => selectedType = weapon['type'] ?? 'Sword');
    
    _openModal(title: 'Edit Item', buttonLabel: 'Update', onSubmit: () => _updateWeapon(weapon['id']));
  }

  void _openModal({required String title, required String buttonLabel, required VoidCallback onSubmit}) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                _buildModalField(nameController, 'Item Name (Min. 3 characters)'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedType,
                            isExpanded: true,
                            style: GoogleFonts.lora(fontSize: 13, color: AppColors.textPrimary),
                            items: weaponTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                            onChanged: (val) => setModalState(() => selectedType = val!),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(flex: 2, child: _buildModalField(priceController, 'Price', keyboardType: TextInputType.number)),
                    const SizedBox(width: 8),
                    Expanded(flex: 2, child: _buildModalField(stockController, 'Stock', keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 10),
                _buildModalField(imageController, 'Image URL'),
                const SizedBox(height: 20),
                Center(
                  child: CustomButton(
                    text: buttonLabel, isLoading: _isSubmitting, width: double.infinity,
                    onPressed: () {
                      Navigator.pop(context);
                      onSubmit();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModalField(TextEditingController controller, String hint, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller, keyboardType: keyboardType,
      style: GoogleFonts.lora(fontSize: 13, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primaryAmberDark)),
      ),
    );
  }

  List<Widget> get _pages => [
    _AdminInventoryPage(
      weapons: weapons,
      isLoading: _isLoading,
      onEdit: _showEditModal,
      onDelete: (id) => _deleteWeapon(id),
      onAdjustStock: _adjustStock,
      onAdd: _showInsertModal,
    ),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        isAdmin: true,
      ),
    );
  }
}

class _AdminInventoryPage extends StatelessWidget {
  final List<dynamic> weapons;
  final bool isLoading;
  final Function(dynamic) onEdit;
  final Function(int) onDelete;
  final Function(int, int) onAdjustStock;
  final VoidCallback onAdd;

  const _AdminInventoryPage({
    required this.weapons,
    required this.isLoading,
    required this.onEdit,
    required this.onDelete,
    required this.onAdjustStock,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: onAdd,
        backgroundColor: AppColors.primaryAmberDark,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [AppColors.bgLightBlue, AppColors.bgWhite],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Admin Treasury', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryAmberDark)),
                          Text('Manage Realm Inventory', style: GoogleFonts.lora(color: AppColors.textSecondary, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: isLoading 
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryAmberDark))
                  : weapons.isEmpty
                    ? Center(child: Text('No weapons found', style: GoogleFonts.lora(color: AppColors.textSecondary)))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80), 
                        itemCount: weapons.length,
                        itemBuilder: (context, index) {
                          return _WeaponAdminCard(
                            weapon: weapons[index],
                            onEdit: () => onEdit(weapons[index]),
                            onDelete: () => onDelete(weapons[index]['id']),
                            onAdjustStock: (delta) => onAdjustStock(index, delta),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeaponAdminCard extends StatelessWidget {
  final dynamic weapon;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(int) onAdjustStock;

  const _WeaponAdminCard({
    required this.weapon,
    required this.onEdit,
    required this.onDelete,
    required this.onAdjustStock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 60, height: 60, color: AppColors.bgLightBlue,
                  child: Image.network(
                    weapon['image'] ?? 'https://via.placeholder.com/150',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, color: AppColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(weapon['name'] ?? 'Unknown', style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
                    Text('Stock: ${weapon['stock']} | Price: ${weapon['price']}', style: GoogleFonts.lora(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(onPressed: onEdit, icon: const Icon(Icons.edit, size: 20, color: AppColors.textSecondary), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
              const SizedBox(width: 16),
              IconButton(onPressed: onDelete, icon: const Icon(Icons.delete, size: 20, color: AppColors.errorRed), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(30)),
            child: Row(
              children: [
                Text('Adjust Stock:', style: GoogleFonts.lora(color: AppColors.textSecondary, fontSize: 13)),
                const Spacer(),
                GestureDetector(
                  onTap: () => onAdjustStock(-1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: const Text('−', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ),
                ),
                const SizedBox(width: 16),
                Text('${weapon['stock'] ?? 0}', style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => onAdjustStock(1),
                  child: Container(
                     padding: const EdgeInsets.symmetric(horizontal: 8),
                     child: const Text('+', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryAmberDark)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}