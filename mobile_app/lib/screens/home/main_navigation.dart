import 'package:flutter/material.dart';
import 'dart:ui';
import '../../utils/constants.dart';
import '../../widgets/glass_card.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../auth/login_screen.dart';
import '../admin/pending_users_screen.dart';
import '../admin/all_receipts_screen.dart';
import '../admin/banks_screen.dart';
import '../admin/all_users_screen.dart';
import 'dashboard_screen.dart';
import 'upload_receipt_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    setState(() {
      _userData = _storageService.getUserData();
    });
  }

  // Build screens list dynamically based on user role
  List<Widget> _buildScreens() {
    final baseScreens = [
      const DashboardScreen(showBottomNav: false),
      const UploadReceiptScreen(showBottomNav: false),
      const HistoryScreen(showBottomNav: false),
    ];

    if (_userData['is_admin'] == true) {
      return [
        ...baseScreens,
        const PendingUsersScreen(showBottomNav: true),
        const AllReceiptsScreen(showBottomNav: true),
        const BanksScreen(showBottomNav: true),
        const AllUsersScreen(showBottomNav: true),
      ];
    }

    return baseScreens;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allows content to extend behind the bottom nav bar
      drawer: _buildGlassDrawer(),
      body: IndexedStack(
        index: _currentIndex,
        children: _buildScreens(),
      ),
      bottomNavigationBar: _buildGlassBottomNavBar(),
    );
  }

  Widget _buildGlassBottomNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          borderRadius: BorderRadius.circular(24),
          blur: 15,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.dashboard,
                label: 'Dashboard',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.add_photo_alternate,
                label: 'Upload',
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.history,
                label: 'History',
                index: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _currentIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _currentIndex = index;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryOrange.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected ? AppColors.primaryOrange : AppColors.lightGray,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.primaryOrange : AppColors.lightGray,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassDrawer() {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F0F0F),
              const Color(0xFF1A1A1A),
              const Color(0xFF1F1F1F),
              const Color(0xFF2D1B00),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: SafeArea(
              child: Column(
                children: [
                  // User Profile Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Profile Avatar
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primaryOrange,
                                AppColors.primaryOrange.withOpacity(0.8),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryOrange.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 0,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 40,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // User Name
                        Text(
                          _userData['full_name']?.toString() ?? 'User',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        // Username
                        Text(
                          '@${_userData['username']?.toString() ?? ''}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.lightGray,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Admin Badge
                        if (_userData['is_admin'] == true)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryOrange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primaryOrange.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'ADMIN',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryOrange,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const Divider(
                    color: AppColors.lightGray,
                    thickness: 0.5,
                    indent: 16,
                    endIndent: 16,
                  ),

                  // Menu Items
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        _buildDrawerItem(
                          icon: Icons.dashboard,
                          title: 'Dashboard',
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              _currentIndex = 0;
                            });
                          },
                        ),

                        // Admin-specific menu items
                        if (_userData['is_admin'] == true) ...[
                          _buildDrawerItem(
                            icon: Icons.pending_actions,
                            title: 'Pending Users',
                            onTap: () {
                              Navigator.pop(context);
                              setState(() {
                                _currentIndex = 3;
                              });
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.receipt_long,
                            title: 'All Receipts',
                            onTap: () {
                              Navigator.pop(context);
                              setState(() {
                                _currentIndex = 4;
                              });
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.account_balance,
                            title: 'Banks',
                            onTap: () {
                              Navigator.pop(context);
                              setState(() {
                                _currentIndex = 5;
                              });
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.people,
                            title: 'Users',
                            onTap: () {
                              Navigator.pop(context);
                              setState(() {
                                _currentIndex = 6;
                              });
                            },
                          ),
                        ],

                        // Regular user menu items
                        if (_userData['is_admin'] != true) ...[
                          _buildDrawerItem(
                            icon: Icons.add_photo_alternate,
                            title: 'Upload Receipt',
                            onTap: () {
                              Navigator.pop(context);
                              setState(() {
                                _currentIndex = 1;
                              });
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.history,
                            title: 'History',
                            onTap: () {
                              Navigator.pop(context);
                              setState(() {
                                _currentIndex = 2;
                              });
                            },
                          ),
                        ],

                        const Divider(
                          color: AppColors.lightGray,
                          thickness: 0.5,
                          indent: 16,
                          endIndent: 16,
                        ),
                        _buildDrawerItem(
                          icon: Icons.person_outline,
                          title: 'Profile',
                          onTap: () {
                            Navigator.pop(context);
                            // TODO: Navigate to profile screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile screen coming soon!'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                        _buildDrawerItem(
                          icon: Icons.settings_outlined,
                          title: 'Settings',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                          },
                        ),
                        _buildDrawerItem(
                          icon: Icons.info_outline,
                          title: 'About',
                          onTap: () {
                            Navigator.pop(context);
                            _showAboutDialog();
                          },
                        ),
                      ],
                    ),
                  ),

                  // Logout Button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: GlassCard(
                      padding: EdgeInsets.zero,
                      child: InkWell(
                        onTap: _logout,
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.logout,
                                color: AppColors.dangerRed,
                                size: 24,
                              ),
                              SizedBox(width: 16),
                              Text(
                                'Logout',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.dangerRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Version Info
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.lightGray.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.lightGray,
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 4,
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(color: AppColors.white),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppColors.lightGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.lightGray),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.dangerRed),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'About E-Receipt',
          style: TextStyle(color: AppColors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Version 1.0.0',
              style: TextStyle(
                color: AppColors.lightGray,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '© 2025 Moinfotech Company Limited',
              style: TextStyle(
                color: AppColors.lightGray,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'All rights reserved',
              style: TextStyle(
                color: AppColors.lightGray,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(color: AppColors.primaryOrange),
            ),
          ),
        ],
      ),
    );
  }
}
