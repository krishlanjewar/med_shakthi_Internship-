import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:med_shakthi/src/features/auth/presentation/screens/login_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  File? _profileImage;
  final _picker = ImagePicker();

  bool _isLoading = false;
  String _email = 'Loading...';
  String _displayName = 'User';
  String _phone = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      // Try to get name from user metadata if available
      final metaName = user.userMetadata?['name'] ?? user.userMetadata?['full_name'];

      setState(() {
        _email = user.email ?? '';
        _phone = user.phone ?? '';
        // If metadata name is missing, use the part of email before '@'
        _displayName = metaName ?? _email.split('@')[0];
      });

      // Optional: Fetch additional details from your 'users' table if you have one
      try {
        final data = await supabase
            .from('users')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (data != null && mounted) {
          setState(() {
            _displayName = data['name'] ?? _displayName;
            _phone = data['phone'] ?? _phone;
          });
        }
      } catch (_) {
        // Silently fail if table doesn't exist or error occurs
      }
    }
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoading = true);
    try {
      await supabase.auth.signOut();
      if (!mounted) return;

      // Navigate to Login Page and remove all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickProfileImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (picked != null) {
      setState(() => _profileImage = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use existing theme & colors from MaterialApp
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey[50], // Fallback if colorScheme.background isn't set
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text('Account', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            // TOP PROFILE CARD
            Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // PROFILE AVATAR WITH EDIT OPTION
                  InkWell(
                    borderRadius: BorderRadius.circular(48),
                    onTap: _pickProfileImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Hero(
                          tag: 'user-avatar',
                          child: CircleAvatar(
                            radius: 34,
                            backgroundColor: const Color(0xFF6AA39B).withOpacity(0.12),
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : null,
                            child: _profileImage == null
                                ? Text(
                              _displayName.isNotEmpty ? _displayName[0].toUpperCase() : 'U',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: const Color(0xFF6AA39B),
                                fontWeight: FontWeight.w600,
                              ),
                            )
                                : null,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const CircleAvatar(
                            radius: 10,
                            backgroundColor: Color(0xFF6AA39B),
                            child: Icon(
                              Icons.edit,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // NAME + EMAIL + PHONE
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _email,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                        if (_phone.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            _phone,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // CALL & CART ICONS
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _IconCircleButton(
                        icon: Icons.shopping_bag_outlined,
                        onTap: () {
                          // TODO: open orders
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // SCROLLABLE CONTENT
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 8),

                  // Business/Address Info (Static for now, can be dynamic later)
                  _SectionTile(
                    title: 'Address',
                    subtitle: 'Your saved shipping addresses',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Manage your addresses here.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _SimpleExpansionTile(title: 'My Orders'),
                  const _SimpleExpansionTile(title: 'Payment Methods'),
                  const _SimpleExpansionTile(title: 'Settings'),
                  const SizedBox(height: 24),

                  // ACTION BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // TODO: change password logic
                          },
                          child: const Text('Change Password'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade600,
                          ),
                          onPressed: () {
                            // TODO: delete account logic
                          },
                          child: const Text('Delete Account'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // LOGOUT BUTTON
                  FilledButton(
                    onPressed: _handleLogout,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF6AA39B),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Logout'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable small circular icon button
class _IconCircleButton extends StatelessWidget {
  const _IconCircleButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF6AA39B).withOpacity(0.1),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFF6AA39B),
          ),
        ),
      ),
    );
  }
}

// Collapsible section with title + subtitle + child content
class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding:
          const EdgeInsets.fromLTRB(16, 0, 16, 12),
          title: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
            ),
          ),
          children: [child],
        ),
      ),
    );
  }
}

// Reusable collapsed tiles
class _SimpleExpansionTile extends StatelessWidget {
  const _SimpleExpansionTile({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          children: const [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tap to view details.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}