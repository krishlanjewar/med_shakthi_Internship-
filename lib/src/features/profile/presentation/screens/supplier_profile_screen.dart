import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:med_shakthi/src/features/auth/presentation/screens/login_page.dart';

class SupplierProfileScreen extends StatefulWidget {
  const SupplierProfileScreen({super.key});

  @override
  State<SupplierProfileScreen> createState() => _SupplierProfileScreenState();
}

class _SupplierProfileScreenState extends State<SupplierProfileScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  bool _isLoading = false;

  // Placeholder Data - Connect to your 'suppliers' table later
  String _companyName = 'Loading...';
  String _email = '';
  String _status = 'Verified';

  @override
  void initState() {
    super.initState();
    _fetchSupplierData();
  }

  Future<void> _fetchSupplierData() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      setState(() {
        _email = user.email ?? '';
        // Basic fallback name
        _companyName = user.userMetadata?['company_name'] ?? 'My Company';
      });

      // TODO: Fetch detailed supplier data from 'suppliers' table using user.id
      try {
        final data = await supabase
            .from('suppliers')
            .select()
            .eq('user_id', user.id)
            .maybeSingle();

        if (data != null && mounted) {
          setState(() {
            _companyName = data['company_name'] ?? _companyName;
            _status = data['verification_status'] ?? _status;
          });
        }
      } catch (e) {
        // Handle error silently
      }
    }
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoading = true);
    try {
      await supabase.auth.signOut();
      if (!mounted) return;

      // Navigate to Login Page
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        title: const Text('Supplier Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: const Color(0xFF4C8077).withOpacity(0.1),
                    child: const Icon(Icons.store, size: 35, color: Color(0xFF4C8077)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _companyName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _email,
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _status == 'Verified' ? Colors.green[50] : Colors.amber[50],
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: _status == 'Verified' ? Colors.green : Colors.amber,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            _status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _status == 'Verified' ? Colors.green[700] : Colors.amber[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Menu Sections
            _buildSectionTitle('Business'),
            _buildMenuOption(Icons.inventory, 'Manage Products', () {}),
            _buildMenuOption(Icons.analytics, 'Sales Reports', () {}),
            _buildMenuOption(Icons.description, 'Invoices', () {}),

            const SizedBox(height: 24),

            _buildSectionTitle('Account'),
            _buildMenuOption(Icons.verified_user, 'Verification Details', () {}),
            _buildMenuOption(Icons.settings, 'Settings', () {}),
            _buildMenuOption(Icons.help, 'Supplier Support', () {}),

            const SizedBox(height: 40),

            // Logout
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleLogout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red.withOpacity(0.2)),
                  ),
                ),
                child: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOption(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF4C8077).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF4C8077), size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}